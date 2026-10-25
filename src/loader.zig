const Card = @import("stack.zig").Card;
const CardType = @import("stack.zig").CardType;
const rl = @import("raylib");
const c = @import("common.zig");

pub fn loadCards() [52]Card {
    var cards: [52]Card = undefined;

    for(0..52) |i| {
        const i_float = @as(f32, @floatFromInt(i));
        const x_index: f32 = @mod(i_float, c.SPRITE_SHEET_WIDTH);
        
        const x_coord = x_index * c.SPRITE_SHEET_CARD_WIDTH;
        const y_index = @divTrunc(i_float, c.SPRITE_SHEET_WIDTH);
        const y_coord = y_index * c.SPRITE_SHEET_CARD_HEIGHT;

        const card: Card = .{
            .id = @as(i32, @intCast(i)),
            .spriteSheetOffset = .{ 
                .x = 0 + x_coord, 
                .y = 0 + y_coord, 
                .width = c.SPRITE_SHEET_CARD_WIDTH, 
                .height = c.SPRITE_SHEET_CARD_HEIGHT
            },
            .type = getCardType(@as(i32, @trunc(y_index))),
            .value = @as(i32, @trunc(x_index + 1)),
            .hidden = false,
        };

        cards[i] = card;
    }
    return cards;
}

fn getCardType(y_index: i32) CardType {
    return switch (y_index) {
        0 => CardType.clubs,
        1 => CardType.diamonds,
        2 => CardType.hearts,
        3 => CardType.spades,
        else => CardType.clubs
    };
}
