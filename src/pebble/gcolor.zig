/// Pebble GColor type and named color constants
///
/// GColor8 is an 8-bit ARGB value with 2 bits per channel.
/// Bit layout: AARRGGBB — alpha 0=transparent, 3=opaque; each channel 0–3.
const std = @import("std");

pub const GColor = extern struct {
    argb: u8,
};

pub fn makeColor(a: u2, r: u2, g: u2, b: u2) GColor {
    return GColor{
        .argb = (@as(u8, a) << 6) | (@as(u8, r) << 4) | (@as(u8, g) << 2) | @as(u8, b),
    };
}

pub fn getAlpha(color: GColor) u2 { return @intCast((color.argb >> 6) & 0x03); }
pub fn getRed(color: GColor) u2   { return @intCast((color.argb >> 4) & 0x03); }
pub fn getGreen(color: GColor) u2 { return @intCast((color.argb >> 2) & 0x03); }
pub fn getBlue(color: GColor) u2  { return @intCast(color.argb & 0x03); }

pub fn equal(a: GColor, b: GColor) bool { return a.argb == b.argb; }
pub fn isTransparent(color: GColor) bool { return getAlpha(color) == 0; }

// Basic
pub const GColorClear   = GColor{ .argb = 0b00000000 };
pub const GColorBlack   = GColor{ .argb = 0b11000000 };
pub const GColorWhite   = GColor{ .argb = 0b11111111 };

// Primary
pub const GColorRed     = GColor{ .argb = 0b11110000 };
pub const GColorGreen   = GColor{ .argb = 0b11001100 };
pub const GColorBlue    = GColor{ .argb = 0b11000011 };

// Secondary
pub const GColorYellow  = GColor{ .argb = 0b11111100 };
pub const GColorCyan    = GColor{ .argb = 0b11001111 };
pub const GColorMagenta = GColor{ .argb = 0b11110011 };
pub const GColorOrange  = GColor{ .argb = 0b11110100 };

// Grayscale
pub const GColorDarkGray  = GColor{ .argb = 0b11010101 };
pub const GColorLightGray = GColor{ .argb = 0b11101010 };

// Named palette
pub const GColorArmyGreen              = GColor{ .argb = 0b11010000 };
pub const GColorBabyBlueEyes           = GColor{ .argb = 0b11010111 };
pub const GColorBlueMoon               = GColor{ .argb = 0b11010110 };
pub const GColorBrass                  = GColor{ .argb = 0b11010100 };
pub const GColorBrightGreen            = GColor{ .argb = 0b11011100 };
pub const GColorBrilliantRose          = GColor{ .argb = 0b11110110 };
pub const GColorBulgariGreen           = GColor{ .argb = 0b11100100 };
pub const GColorCadetBlue              = GColor{ .argb = 0b11011010 };
pub const GColorCeleste                = GColor{ .argb = 0b11011111 };
pub const GColorChromeYellow           = GColor{ .argb = 0b11101000 };
pub const GColorCobaltBlue             = GColor{ .argb = 0b11000111 };
pub const GColorDarkGreen              = GColor{ .argb = 0b11000100 };
pub const GColorDukeBlue               = GColor{ .argb = 0b11000010 };
pub const GColorElectricBlue           = GColor{ .argb = 0b11011111 };
pub const GColorElectricUltramarine    = GColor{ .argb = 0b11001001 };
pub const GColorFashionMagenta         = GColor{ .argb = 0b11110010 };
pub const GColorFolly                  = GColor{ .argb = 0b11110001 };
pub const GColorIcterine               = GColor{ .argb = 0b11111101 };
pub const GColorImperialPurple         = GColor{ .argb = 0b11010010 };
pub const GColorInchworm               = GColor{ .argb = 0b11101101 };
pub const GColorIndigo                 = GColor{ .argb = 0b11000110 };
pub const GColorIslamicGreen           = GColor{ .argb = 0b11001000 };
pub const GColorJaegerGreen            = GColor{ .argb = 0b11011001 };
pub const GColorJazzberryJam           = GColor{ .argb = 0b11100010 };
pub const GColorLavenderIndigo         = GColor{ .argb = 0b11110111 };
pub const GColorLiberty                = GColor{ .argb = 0b11000001 };
pub const GColorLimerick               = GColor{ .argb = 0b11101000 };
pub const GColorMalachite              = GColor{ .argb = 0b11001100 };
pub const GColorMayGreen               = GColor{ .argb = 0b11011000 };
pub const GColorMediumAquamarine       = GColor{ .argb = 0b11011110 };
pub const GColorMediumSpringGreen      = GColor{ .argb = 0b11001110 };
pub const GColorMelon                  = GColor{ .argb = 0b11110101 };
pub const GColorMidnightGreen          = GColor{ .argb = 0b11000101 };
pub const GColorMintGreen              = GColor{ .argb = 0b11011101 };
pub const GColorOxfordBlue             = GColor{ .argb = 0b11000001 };
pub const GColorPastelYellow           = GColor{ .argb = 0b11111110 };
pub const GColorPictonBlue             = GColor{ .argb = 0b11011011 };
pub const GColorPurple                 = GColor{ .argb = 0b11010011 };
pub const GColorRajah                  = GColor{ .argb = 0b11110101 };
pub const GColorRedMoon                = GColor{ .argb = 0b11100000 };
pub const GColorRichBrilliantLavender  = GColor{ .argb = 0b11110111 };
pub const GColorRichElectricBlue       = GColor{ .argb = 0b11000110 };
pub const GColorScreaminGreen          = GColor{ .argb = 0b11011100 };
pub const GColorShockingPink           = GColor{ .argb = 0b11110110 };
pub const GColorSpringBud              = GColor{ .argb = 0b11101100 };
pub const GColorSunsetOrange           = GColor{ .argb = 0b11110100 };
pub const GColorTiffanyBlue            = GColor{ .argb = 0b11001101 };
pub const GColorVeryLightBlue          = GColor{ .argb = 0b11101011 };
pub const GColorVividCerulean          = GColor{ .argb = 0b11001010 };
pub const GColorVividViolet            = GColor{ .argb = 0b11100011 };
pub const GColorWindsorTan             = GColor{ .argb = 0b11100100 };
pub const GColorYellowGreen            = GColor{ .argb = 0b11101100 };

pub const ColorEntry = struct { name: []const u8, color: GColor };

pub const COLOR_PALETTE = [_]ColorEntry{
    .{ .name = "Clear",                  .color = GColorClear },
    .{ .name = "Black",                  .color = GColorBlack },
    .{ .name = "White",                  .color = GColorWhite },
    .{ .name = "Red",                    .color = GColorRed },
    .{ .name = "Green",                  .color = GColorGreen },
    .{ .name = "Blue",                   .color = GColorBlue },
    .{ .name = "Yellow",                 .color = GColorYellow },
    .{ .name = "Cyan",                   .color = GColorCyan },
    .{ .name = "Magenta",                .color = GColorMagenta },
    .{ .name = "Orange",                 .color = GColorOrange },
    .{ .name = "DarkGray",               .color = GColorDarkGray },
    .{ .name = "LightGray",              .color = GColorLightGray },
    .{ .name = "ArmyGreen",              .color = GColorArmyGreen },
    .{ .name = "BabyBlueEyes",           .color = GColorBabyBlueEyes },
    .{ .name = "BlueMoon",               .color = GColorBlueMoon },
    .{ .name = "Brass",                  .color = GColorBrass },
    .{ .name = "BrightGreen",            .color = GColorBrightGreen },
    .{ .name = "BrilliantRose",          .color = GColorBrilliantRose },
    .{ .name = "BulgariGreen",           .color = GColorBulgariGreen },
    .{ .name = "CadetBlue",              .color = GColorCadetBlue },
    .{ .name = "Celeste",                .color = GColorCeleste },
    .{ .name = "ChromeYellow",           .color = GColorChromeYellow },
    .{ .name = "CobaltBlue",             .color = GColorCobaltBlue },
    .{ .name = "DarkGreen",              .color = GColorDarkGreen },
    .{ .name = "DukeBlue",               .color = GColorDukeBlue },
    .{ .name = "ElectricBlue",           .color = GColorElectricBlue },
    .{ .name = "ElectricUltramarine",    .color = GColorElectricUltramarine },
    .{ .name = "FashionMagenta",         .color = GColorFashionMagenta },
    .{ .name = "Folly",                  .color = GColorFolly },
    .{ .name = "Icterine",               .color = GColorIcterine },
    .{ .name = "ImperialPurple",         .color = GColorImperialPurple },
    .{ .name = "Inchworm",               .color = GColorInchworm },
    .{ .name = "Indigo",                 .color = GColorIndigo },
    .{ .name = "IslamicGreen",           .color = GColorIslamicGreen },
    .{ .name = "JaegerGreen",            .color = GColorJaegerGreen },
    .{ .name = "JazzberryJam",           .color = GColorJazzberryJam },
    .{ .name = "LavenderIndigo",         .color = GColorLavenderIndigo },
    .{ .name = "Liberty",                .color = GColorLiberty },
    .{ .name = "Limerick",               .color = GColorLimerick },
    .{ .name = "Malachite",              .color = GColorMalachite },
    .{ .name = "MayGreen",               .color = GColorMayGreen },
    .{ .name = "MediumAquamarine",       .color = GColorMediumAquamarine },
    .{ .name = "MediumSpringGreen",      .color = GColorMediumSpringGreen },
    .{ .name = "Melon",                  .color = GColorMelon },
    .{ .name = "MidnightGreen",          .color = GColorMidnightGreen },
    .{ .name = "MintGreen",              .color = GColorMintGreen },
    .{ .name = "OxfordBlue",             .color = GColorOxfordBlue },
    .{ .name = "PastelYellow",           .color = GColorPastelYellow },
    .{ .name = "PictonBlue",             .color = GColorPictonBlue },
    .{ .name = "Purple",                 .color = GColorPurple },
    .{ .name = "Rajah",                  .color = GColorRajah },
    .{ .name = "RedMoon",                .color = GColorRedMoon },
    .{ .name = "RichBrilliantLavender",  .color = GColorRichBrilliantLavender },
    .{ .name = "RichElectricBlue",       .color = GColorRichElectricBlue },
    .{ .name = "ScreaminGreen",          .color = GColorScreaminGreen },
    .{ .name = "ShockingPink",           .color = GColorShockingPink },
    .{ .name = "SpringBud",              .color = GColorSpringBud },
    .{ .name = "SunsetOrange",           .color = GColorSunsetOrange },
    .{ .name = "TiffanyBlue",            .color = GColorTiffanyBlue },
    .{ .name = "VeryLightBlue",          .color = GColorVeryLightBlue },
    .{ .name = "VividCerulean",          .color = GColorVividCerulean },
    .{ .name = "VividViolet",            .color = GColorVividViolet },
    .{ .name = "WindsorTan",             .color = GColorWindsorTan },
    .{ .name = "YellowGreen",            .color = GColorYellowGreen },
};

/// Looks up a color by name (case-insensitive). Returns null if not found.
pub fn fromName(name: []const u8) ?GColor {
    for (COLOR_PALETTE) |entry| {
        if (std.ascii.eqlIgnoreCase(entry.name, name)) return entry.color;
    }
    return null;
}
