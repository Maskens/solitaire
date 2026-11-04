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
