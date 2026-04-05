import Testing
@testable import EkocciShared

@Suite("SpriteMapping Tests")
struct SpriteMappingTests {

    @Test("全レジストリキャラクターにスプライト情報がある")
    func allCharactersHaveMapping() {
        for character in CharacterRegistry.allCharacters {
            let info = SpriteMapping.spriteInfo(for: character.id)
            #expect(!info.emoji.isEmpty, "Missing emoji for \(character.id)")
        }
    }

    @Test("絵文字がレジストリのものと一致する")
    func emojiMatchesRegistry() {
        for character in CharacterRegistry.allCharacters {
            let mappedEmoji = SpriteMapping.emoji(for: character.id)
            #expect(mappedEmoji == character.emoji,
                    "\(character.id): mapping=\(mappedEmoji) vs registry=\(character.emoji)")
        }
    }

    @Test("不明なIDにはフォールバックが返る")
    func fallbackForUnknown() {
        let info = SpriteMapping.spriteInfo(for: "nonexistent_xyz")
        #expect(info.emoji == "❓")
        #expect(info.tintHue == nil)
    }

    @Test("ステージプレフィックスでフォールバックが適切")
    func stagePrefixFallback() {
        #expect(SpriteMapping.emoji(for: "baby_unknown") == "🐣")
        #expect(SpriteMapping.emoji(for: "child_unknown") == "🐥")
        #expect(SpriteMapping.emoji(for: "adult_unknown") == "🐔")
    }

    @Test("特別キャラクターにアクセサリがある")
    func specialCharactersHaveAccessories() {
        let ecoMaster = SpriteMapping.spriteInfo(for: "adult_eco_master")
        #expect(ecoMaster.accessory == "🌱")

        let eternal = SpriteMapping.spriteInfo(for: "senior_eternal")
        #expect(eternal.accessory == "👑")
    }
}
