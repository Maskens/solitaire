const rl = @import("raylib");
const std = @import("std");
const Stack = @import("stack.zig").Stack;
const Card = @import("stack.zig").Card;
const loader = @import("loader.zig");
const c = @import("common.zig");

pub const Game = struct {
    stacks: [7]Stack = undefined,
    cardSpriteSheet: rl.Texture2D,
    pub inline fn init() !Game {

        const cards_texture = try rl.loadTexture("resources/classic_13x4x560x780.png");
        rl.setTextureFilter(cards_texture, rl.TextureFilter.bilinear);

        var allCards = loader.loadCards();
        // Shuffle the cards
        var prng: std.Random.DefaultPrng = .init(1125958);
        const rand = prng.random();

        std.Random.shuffle(rand, Card, &allCards);

        var game = Game {
            .cardSpriteSheet = cards_texture
        };

        const startX: f32 = 10;
        const startY: f32 = 100;
        const offsetX: f32 = 60;

        var numberOfCardsToAdd: usize = 1;
        var currentCard: usize = 0;
        for (&game.stacks, 0..) |*stack, i| {
            const _i = @as(u8, @intCast(i));
            stack.* = Stack.init(_i + 1, .{ .x = startX * _i + offsetX * _i, .y = startY});

            for (0..numberOfCardsToAdd+1) |_| {
                try stack.*.addCard(allCards[currentCard]);
                currentCard += 1;
                rl.traceLog(.info, "%d", .{currentCard});
            }

            numberOfCardsToAdd += 1;
        }

        for (game.stacks) |stack| {
            rl.traceLog(.info, "Stack id %d", .{stack.id});
        }

        // // Rewrite this
        // var stack = Stack.init(1, .{ .x = startX, .y = startY});
        // try stack.addCard(allCards[0]);
        //
        // var stack2 = Stack.init(2, .{ .x = startX + offsetX, .y = startY});
        // try stack2.addCard(allCards[1]);
        // try stack2.addCard(allCards[2]);
        //
        // var stack3 = Stack.init(3, .{ .x = startX + offsetX * 2, .y = startY});
        // try stack3.addCard(allCards[3]);
        // try stack3.addCard(allCards[4]);
        // try stack3.addCard(allCards[5]);
        //
        // var stack4 = Stack.init(4, .{ .x = startX + offsetX * 3, .y = startY});
        // try stack4.addCard(allCards[6]);
        // try stack4.addCard(allCards[7]);
        // try stack4.addCard(allCards[8]);
        // try stack4.addCard(allCards[9]);
        //
        // game.stacks[0] = stack;
        // game.stacks[1] = stack2;
        // game.stacks[2] = stack3;
        // game.stacks[3] = stack4;
        //
        return game;
    }

    pub fn deinit(self: *Game) void {
        rl.unloadTexture(self.cardSpriteSheet);
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
            stack.draw(&self.cardSpriteSheet);
        }
    }
};


