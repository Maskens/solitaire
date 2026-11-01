const rl = @import("raylib");
const c = @import("common.zig");
const std = @import("std");
const Allocator = std.mem.Allocator;

pub const CardType = enum {
    spades,
    diamonds,
    clubs,
    hearts
};

pub const CardColor = enum {
    red,
    black
};

pub const Card = struct {
    id: i32,
    spriteSheetOffset: rl.Rectangle, // Where on the sprite sheet we draw this card
    type: CardType,
    value: i32,
    hidden: bool = true,

    pub fn getPosRect(_: *Card, position: rl.Vector2, i: usize) rl.Rectangle {
        const _i = @as(f32, @floatFromInt(i));
        return .{
            .x = position.x,
            .y = position.y + c.STACK_CARD_GAP * _i,
            .width = c.CARD_WIDTH,
            .height = c.CARD_HEIGHT
        };
    }

    pub fn getCardColor(self: *const Card) CardColor {
        return switch (self.type) {
            .spades, .clubs => .black,
            .diamonds, .hearts => .red
        };
    }
};

pub const Stack = struct {
    id: u8,
    position: rl.Vector2,
    items_array: std.ArrayList(Card) = undefined,

    pub fn init(alloc: Allocator, id: u8, position: rl.Vector2) !Stack {
        return Stack {
            .id = id,
            .position = position,
            .items_array = try std.ArrayList(Card).initCapacity(alloc, 25)
        };
    }

    // Gets a card if its in the stack, returns delta pos of card
    pub fn getCardStackClicked(self: *Stack, alloc: Allocator, point: rl.Vector2, targetStack: *Stack) !?rl.Vector2 {
        if (self.items_array.items.len == 0) { //SHould this guard be here or at call site?
            return null;
        }

        var i = self.items_array.items.len - 1;
        var cardCollision: bool = false;
        var collisionDelta: ?rl.Vector2 = null;

        while(i >= 0) {
            const card = &self.items_array.items[i];

            if (rl.checkCollisionPointRec(point, card.getPosRect(self.position, i))) {
                // rl.traceLog(.info, "Card id clicked: %d", .{card.id });
                collisionDelta = .{
                    .x = point.x - card.getPosRect(self.position, i).x,
                    .y = point.y - card.getPosRect(self.position, i).y
                };
                cardCollision = true;
                break;
            }

            if (i == 0) {
                break;
            }

            i -= 1;
        }

        if (!cardCollision) {
            return null;
        }

        var buf: [25]Card = undefined;
        var tempList = std.ArrayList(Card).initBuffer(&buf);

        while(self.items_array.items.len > i) {
            const item = self.items_array.pop() orelse return null; 
            try tempList.insert(alloc, 0, item);
        }

        for(tempList.items) |item| {
            try targetStack.items_array.append(alloc, item);
        }
        return collisionDelta;
    }

    pub fn draw(self: *const Stack, spriteSheet: rl.Texture2D) void {
        rl.drawRectangleLinesEx(
            .{
                .x = self.position.x,
                .y = self.position.y,
                .width = c.CARD_WIDTH,
                .height = c.CARD_HEIGHT
            }, 
            2.0,
            .white
        );

        for(self.items_array.items, 0..) |*card, i| {
            const rect = card.getPosRect(self.position, i);

            if (card.hidden) {
                rl.drawRectangleRec(rect, .brown);
                rl.drawRectangleLinesEx(rect, 2.0, .white);
                continue;
            }

            rl.drawTexturePro(
                spriteSheet, 
                card.spriteSheetOffset, 
                rect, 
                .{.x = 0, .y = 0}, 
                0.0, 
                .white
            );
            rl.drawRectangleLinesEx(
                rect,
                0.5, 
                .black
            );
        }
    }

    pub fn getStackBoundsExact(self: *const Stack) rl.Rectangle {
        const height = @as(f32, @floatFromInt(self.items_array.items.len)) * c.STACK_CARD_GAP + c.CARD_HEIGHT - c.STACK_CARD_GAP;
        return .{
            .x = self.position.x,
            .y = self.position.y,
            .width = c.CARD_WIDTH,
            .height = height
        };
    }

    pub fn getDistance(self: *Stack, mousePos: rl.Vector2) f32 {
        const middleX = self.position.x + c.CARD_WIDTH / 2;
        return @abs(middleX - mousePos.x);
    }
};

