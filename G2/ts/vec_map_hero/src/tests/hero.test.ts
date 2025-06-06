import { ENV } from "../env";
import { createHero, getHero } from "../helpers/hero";

describe("Hero", () => {
  it("should create a hero with attributes", async () => {
    const result = await createHero("Hero 1", [
      { name: "fire", level: 10 },
      { name: "water", level: 20 },
      { name: "earth", level: 30 },
      { name: "air", level: 40 },
    ]);
    expect(result.effects?.status.status).toBe("success");
    expect(result.effects?.created?.length).toBe(1);

    let hero = result.effects?.created?.[0];
    expect(hero).toBeDefined();

    const heroData = await getHero(hero?.reference.objectId!);
    expect(heroData).toBeDefined();
    // @ts-ignore
    expect(heroData.data?.content?.fields.name).toBe("Hero 1");
    expect(
      // @ts-ignore
      heroData.data?.content?.fields.attributes.length
    ).toBe(4);

    const attributes =
      // @ts-ignore
      heroData.data?.content?.fields.attributes;
    expect(attributes).toBeDefined();
    expect(attributes?.length).toBe(4);

    const expectedAttributes = [
      { name: "fire", value: 10 },
      { name: "water", value: 20 },
      { name: "earth", value: 30 },
      { name: "air", value: 40 },
    ];

    expect(attributes).toEqual(
      expect.arrayContaining(
        expectedAttributes.map(({ name, value }) =>
          expect.objectContaining({
            fields: {
              level: value.toString(),
              name: name,
            },
            type: `${ENV.PACKAGE_ID}::vecmap_hero::Attribute`,
          })
        )
      )
    );
  });
});
