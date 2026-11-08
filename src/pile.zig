const CardType = @import("stack.zig").CardType;
const Card = @import("stack.zig").Card;
const std = @import("std");
const rl = @import("raylib");
const c = @import("common.zig");

// Represents the piles where cards are stored to win the game
pub const Pile = struct {
    pos: rl.Vector2,
    cards: std.ArrayList(Card),
    type: ?CardType,

    pub fn canAddCard(self: *Pile, card: *const Card) bool {
        if (self.cards.items.len == 0 and card.value == 1) {
            return true;
        }

        if (card.type == self.type and (card.value == self.cards.getLast().value - 1)) {
            return true;
        }

        return false;
    }

    pub fn isNear(self: *Pile, point: rl.Vector2) bool {
        const middlePos: rl.Vector2 = .{
            .x = self.pos.x + @as(f32, @floatFromInt(c.CARD_WIDTH)) / 2,
            .y = self.pos.y + @as(f32, c.CARD_HEIGHT) / 2
        };

        return point.distance(middlePos) < c.CARD_WIDTH; //Todo: Modify this
    }

    pub fn addCard(self: *Pile, alloc: std.mem.Allocator, card: Card) !void {
        try self.cards.append(alloc, card);
    }

    pub fn draw(self: *Pile, spriteSheet: rl.Texture2D) void {
        const rect: rl.Rectangle = .{
            .x = self.pos.x,
            .y = self.pos.y,
            .width = c.CARD_WIDTH,
            .height = c.CARD_HEIGHT
        };

        if (self.cards.items.len == 0) {
            rl.drawRectangleLinesEx(
                rect,
                2.0, 
                .white
            );
        } else {
            const card = self.cards.getLast();
            rl.drawTexturePro(
                spriteSheet, 
                card.spriteSheetOffset, 
                rect, 
                .{.x = 0, .y = 0}, 
                0.0, 
                .white
            );
        }
    }
};
