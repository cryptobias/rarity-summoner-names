const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Names", function () {
  let names;

  before(async function() {
    // deploy the contract
    const Names = await ethers.getContractFactory("Names");
    names = await Names.deploy();
    await names.deployed();

    // load the rarity contract  
    const rarity = await ethers.getContractAt("Rarity", await names.rarity());
    
    // summon an adventure to set the name on
    summoner = await rarity.next_summoner();
    await rarity.summon(11);
  });

  it("should set a summoners name", async function() {
     // set the summoner's name
    await names.setName(summoner, "Harry")
    
    // expect the name to be stored
    await expect(await names.names(summoner)).to.equal("Harry");
  });
});
