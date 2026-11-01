const std = @import("std");
const c = @import("common.zig");
const Stack = @import("stack.zig").Stack;
const Game = @import("game.zig").Game;
const Io = std.Io;
const rl = @import("raylib");

const State = enum {
    nop,
    movingCards,
    dropCards
};

pub fn main(init: std.process.Init) !void {
    const arenaAlloc = init.arena.allocator();
    rl.initWindow(c.SCREEN_WIDTH, c.SCREEN_HEIGHT, "Patience");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var game = try Game.init(arenaAlloc);
    defer game.deinit();

    var state = State.nop;
    var cardsDragged = try Stack.init(arenaAlloc, 0, .{ .x = 0, .y = 0 });
    var deltaPos: rl.Vector2 = .{ .x = 0, .y = 0 };
    var stackSource: *Stack = undefined;

    while(!rl.windowShouldClose()) {
        const mousePos = rl.getMousePosition();

        state: switch (state) {
            .nop => {
                if(rl.isMouseButtonPressed(.left)) {
                    stackSource = game.getStackClicked(mousePos) orelse break :state;

                    rl.traceLog(.info, "%d", .{stackSource.id});
                    const posDelta = try stackSource.getCardStackClicked(
                        arenaAlloc, 
                        mousePos, 
                        &cardsDragged
                    );

                    if (cardsDragged.items_array.items.len > 0) { // We got a stack of cards to move!
                        deltaPos = posDelta.?; 
                        cardsDragged.position = mousePos.subtract(deltaPos);
                        state = .movingCards;
                    }
                }
            },
            .movingCards => {
                if (rl.isMouseButtonDown(.left)) {
                    cardsDragged.position = mousePos.subtract(deltaPos);
                } else {
                    state = .dropCards;
                }

            },
            .dropCards => {
                cardsDragged.position = .{ .x = 0, .y = 0 };

                var targetStackMaybe = try game.getNearestMatchingStack(arenaAlloc, mousePos, &cardsDragged);

                // Rewrite this mess
                if (targetStackMaybe == null) {
                    // Move dragged stack back to original stack
                    while (cardsDragged.items_array.items.len > 0) {
                        const card = cardsDragged.items_array.swapRemove(0);
                        try stackSource.items_array.append(arenaAlloc, card);
                    }

                } else {
                    if (stackSource.getDistance(mousePos) < targetStackMaybe.?.getDistance(mousePos)) {

                        // Move dragged stack back to original stack
                        while (cardsDragged.items_array.items.len > 0) {
                            const card = cardsDragged.items_array.swapRemove(0);
                            try stackSource.items_array.append(arenaAlloc, card);
                        }
                    } else {
                        // Write a function to move cards to another stack
                        while (cardsDragged.items_array.items.len > 0) {
                            const card = cardsDragged.items_array.swapRemove(0);
                            try targetStackMaybe.?.items_array.append(arenaAlloc, card);
                        }
                    }

                }
                state = .nop;
            }
        }

        rl.beginDrawing();

        rl.clearBackground(.black);
        game.draw();

        if (cardsDragged.items_array.items.len > 0) {
            cardsDragged.draw(game.cardSpriteSheet);
        }

        rl.endDrawing();
    }
}
