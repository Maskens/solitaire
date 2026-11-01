const rl = @import("raylib");
const std = @import("std");
const Stack = @import("stack.zig").Stack;
const Card = @import("stack.zig").Card;
const loader = @import("loader.zig");
const c = @import("common.zig");

pub const Game = struct {
    stacks: [7]Stack = undefined,
    cardSpriteSheet: rl.Texture2D,
    pub fn init(alloc: std.mem.Allocator) !Game {
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
        const startY: f32 = c.STACK_ROW_Y;
        const offsetX: f32 = c.STACK_GAP;

        var numberOfCardsToAdd: usize = 1;
        var currentCard: usize = 0;

        for (0..game.stacks.len) |i| {
            const _i = @as(u8, @intCast(i));
            var newStack = try Stack.init(alloc, _i + 1, .{ .x = startX * _i + offsetX * _i, .y = startY});

            for (0..numberOfCardsToAdd+1) |_| {
                try newStack.items_array.append(alloc, allCards[currentCard]);
                currentCard += 1;
            }

            game.stacks[i] = newStack;

            numberOfCardsToAdd += 1;
        }

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
            stack.draw(self.cardSpriteSheet);
        }
    }
};


