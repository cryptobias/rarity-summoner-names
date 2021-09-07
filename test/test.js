const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe("Names", function () {
  let names;
  let summoner;
  let rarity;
  let rarityGold;

  before(async function() {
    // deploy the contract
    const Names = await ethers.getContractFactory("Names");
    names = await Names.deploy();
    await names.deployed();

    expect(await names.burn()).to.not.equal(0);

    // load the rarity contracts
    rarity = await ethers.getContractAt("Rarity", await names.rarity());
    rarityGold = await ethers.getContractAt("RarityGold", await names.rarityGold());

    // summon an adventure to set the name on
    summoner = await rarity.next_summoner();
    await rarity.summon(11);

    // adventure until level up is available
    const requiredXP = await rarity.xp_required(1);
    let currentXP = await rarity.xp(summoner);

    while(currentXP.lt(requiredXP)) {
      // adventure for XP
      await rarity.adventure(summoner);
      currentXP = await rarity.xp(summoner);

      // turn the time forward by a day
      await network.provider.send("evm_increaseTime", [60 * 60 * 24 + 60]);
    }

    // level up
    await rarity.level_up(summoner);
  });

  it("should set a summoners name", async function() {
     // set the summoner's name
    await expect(names.setName(summoner, "Harry")).to.emit(names, "SummonerNamed").withArgs(summoner, "Harry");

    // expect the name to be stored
    await expect(await names.names(summoner)).to.equal("Harry");
  });

  it("should NOT allow to change the name if burn hasn't been approved sufficient funds", async function() {
    // try to rename the summoner and expect it to fail
    await expect(
      names.setName(summoner, "Ron")
    ).to.be.revertedWith("insufficient allowance for rename");
  });

  it("should NOT allow to change the name without sufficient funds", async function() {
    // allow the rename cost to get burned
    await rarityGold.approve(
      summoner,
      await names.burn(),
      await names.nextRenameCost(summoner)
    );

    // try to rename the summoner and expect it to fail
    await expect(
      names.setName(summoner, "Ron")
    ).to.be.revertedWith("insufficient gold for rename");
  });

  it("should allow to change the name with sufficient funds", async function() {
    // remember rename cost
    const renameCostBefore = await names.nextRenameCost(summoner)

    // claim the summoners gold
    rarityGold.claim(summoner);
    const goldBefore = await rarityGold.balanceOf(summoner);

    // rename the summoner
    await names.setName(summoner, "Ron")

    // expect the new name to be stored
    await expect(await names.names(summoner)).to.equal("Ron");

    // expect the summoner's gold to have decreased
    const goldAfter = await rarityGold.balanceOf(summoner);
    await expect(goldAfter).to.be.lt(goldBefore);

    // expect the rename cost to have gone up
    const renameCostAfter = await names.nextRenameCost(summoner)
    await expect(renameCostAfter).to.be.gt(renameCostBefore);
  });

  it("should NOT allow to set a non-owned summoners name", async function() {
    // try to set first summoner's name and expect it to fail
    await expect(
      names.setName(1, "Harry")
    ).to.be.revertedWith("only the owner can set the name of a summoner");
  });
});
