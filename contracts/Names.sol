// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Rarity.sol";
import "./RarityGold.sol";

contract Names {
    // start at the low cost of 100 gold
    uint initialRenameCost = 100e18;

    Rarity public rarity = Rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    RarityGold public rarityGold = RarityGold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2);

    uint public burn; 
    mapping(uint => string) public names;
    mapping(uint => uint) public nextRenameCost;

    event SummonerNamed(uint summoner, string name);

    constructor() {
        // summon a sorcerer to burn gold that is paid for renames
        burn = rarity.next_summoner();
        rarity.summon(10);
    }

    function setName(uint summoner, string memory name) external {
        require(msg.sender == rarity.ownerOf(summoner), "only the owner can set the name of a summoner");
        require(rarityGold.allowance(summoner, burn) >= nextRenameCost[summoner], "insufficient allowance for rename");
        require(rarityGold.balanceOf(summoner) >= nextRenameCost[summoner], "insufficient gold for rename");

        // store the name
        names[summoner] = name;
        emit SummonerNamed(summoner, name);

        // calculate the next cost and burt it if necessary
        uint renameCost = nextRenameCost[summoner];
        if(renameCost == 0) {
            nextRenameCost[summoner] = initialRenameCost;
        } else {
            // exponentially increase the costs
            nextRenameCost[summoner] = nextRenameCost[summoner] * 2;
            rarityGold.transferFrom(burn, summoner, burn, renameCost);
        }
    }
}