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

pub fn main(_: std.process.Init) !void {

    var game = try Game.init();

    var state = State.nop;
    var cardsDragged = Stack.init(0, .{ .x = 0, .y = 0 });
    var deltaPos: rl.Vector2 = .{ .x = 0, .y = 0 };
    var stackSource: *Stack = undefined;

    rl.initWindow(c.SCREEN_WIDTH, c.SCREEN_HEIGHT, "Patience");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while(!rl.windowShouldClose()) {
        const mousePos = rl.getMousePosition();
        // State machine
        state: switch (state) {
            .nop => {
                if(rl.isMouseButtonPressed(.left)) {
                    stackSource = game.getStackClicked(mousePos) orelse break :state;

                    rl.traceLog(.info, "%d", .{stackSource.id});
                    const posDelta = try stackSource.getCardStackClicked(mousePos, &cardsDragged);

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

                // Put back the cards into "stack"
                // Todo: Instead of putting back to source stack put them back to a new stack if so
                // Need to calculate which stack is nearest!
                while (cardsDragged.items_array.items.len > 0) {
                    const card = cardsDragged.items_array.swapRemove(0);
                    try stackSource.addCard(card.id);
                }
                
                state = .nop;
            }
        }

        rl.beginDrawing();

        rl.clearBackground(.black);
        game.draw();

        if (cardsDragged.items_array.items.len > 0) {
            cardsDragged.draw();
        }

        rl.endDrawing();
    }
}
