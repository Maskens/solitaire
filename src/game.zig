const rl = @import("raylib");
const std = @import("std");
const Stack = @import("stack.zig").Stack;
const c = @import("common.zig");

pub const Game = struct {
    stacks: [3]Stack = undefined,
    pub inline fn init() !Game {
        var stack = Stack.init(1, .{ .x = 50, .y = 50});
        var stack2 = Stack.init(2, .{ .x = 125, .y = 50});
        var stack3 = Stack.init(3, .{ .x = 200, .y = 50});

        rl.traceLog(.info, "Size of stack initial %d", .{stack.items_array.items.len});
        try stack.addCard(1);
        try stack.addCard(2);
        try stack.addCard(3);
        try stack.addCard(4);
        try stack.addCard(5);

        try stack2.addCard(10);
        try stack2.addCard(11);
        try stack2.addCard(12);
        try stack2.addCard(13);

        try stack3.addCard(14);
        try stack3.addCard(15);
        try stack3.addCard(16);
        try stack3.addCard(17);

        for(stack.items_array.items) |item| {
            std.debug.print("{}\n", .{item});
        }
        rl.traceLog(.info, "Size of stack initial %d", .{stack.items_array.items.len});

        var game = Game {};
        game.stacks[0] = stack;
        game.stacks[1] = stack2;
        game.stacks[2] = stack3;

        return game;
    }

    pub fn getStackClicked(self: *Game, point: rl.Vector2) ?*Stack {
        for(&self.stacks) |*stack| {
            if (rl.checkCollisionPointRec(point, stack.getStackBoundsExact())) {
                return stack;
            }
        }

        return null;
    }

    pub fn getNearestStack(self: *Game, point: rl.Vector2) *Stack {
        var nearestStack: ?*Stack = null;
        var currentDistanceX: ?f32 = null;
        // Get the nearest stack of mouse cursor horizontally
        for(&self.stacks) |*stack| {
            const stackMiddleX = stack.position.x + c.CARD_WIDTH / 2;
            const deltaX = @abs(stackMiddleX - point.x);

            if(nearestStack == null) {
                nearestStack = stack;
                currentDistanceX = deltaX;
            } else {
                if(deltaX < currentDistanceX.?) {
                    nearestStack = stack;
                    currentDistanceX = deltaX;
                }
            }
        }

        return nearestStack.?;
    }

    pub fn draw(self: *Game) void {
        for(self.stacks) |stack| {
            stack.draw();
        }
    }
};


