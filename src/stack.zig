const rl = @import("raylib");
const c = @import("common.zig");
const std = @import("std");

pub const CardType = enum {
    spades,
    diamonds,
    clubs,
    hearts
};

pub const Card = struct {
    id: i32,
    spriteSheetOffset: rl.Rectangle, // Where on the sprite sheet we draw this card
    type: CardType,
    value: i32,
    hidden: bool,

    fn getPosRect(_: *Card, position: rl.Vector2, i: usize) rl.Rectangle {
        const _i = @as(f32, @floatFromInt(i));
        return .{
            .x = position.x,
            .y = position.y + c.STACK_CARD_GAP * _i,
            .width = c.CARD_WIDTH,
            .height = c.CARD_HEIGHT
        };
    }
};

pub const Stack = struct {
    id: u8,
    position: rl.Vector2,
    items_array: std.ArrayList(Card) = undefined,

    pub inline fn init(id: u8, position: rl.Vector2) Stack {
        var buf: [25]Card = undefined;
        var stack = Stack {
            .id = id,
            .position = position,
        };

        stack.items_array = std.ArrayList(Card).initBuffer(&buf);

        return stack;
    }

    pub fn addCard(self: *Stack, card: Card) !void {
        try self.items_array.appendBounded(card);
    }

    // Gets a card if its in the stack, returns delta pos of card
    pub fn getCardStackClicked(self: *Stack, point: rl.Vector2, targetStack: *Stack) !?rl.Vector2 {
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
            try tempList.insertBounded(0, item);
        }

        for(tempList.items) |item| {
            try targetStack.addCard(item);
        }
        return collisionDelta;
    }

    pub fn draw(self: *const Stack, spriteSheet: *rl.Texture2D) void {
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

            rl.drawTexturePro(
                spriteSheet.*, 
                card.spriteSheetOffset, 
                rect, 
                .{.x = 0, .y = 0}, 
                0.0, 
                .white
            );
            // rl.drawRectangleRec(rect, .brown);
            rl.drawRectangleLinesEx(
                rect,
                2.0, 
                .white
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
};

