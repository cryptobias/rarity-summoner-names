// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface Rarity {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    
    // for tests
    function adventure(uint _summoner) external;
    function level_up(uint _summoner) external;
    function next_summoner() external view returns (uint summoner);
    function summon(uint _class) external;
    function xp_required(uint curent_level) external view returns (uint xp_to_next_level);
    function xp(uint _summoner) external view returns (uint xp);
}

interface RarityGold {
    function allowance(uint from, uint spender) external view returns (uint amount);
    function balanceOf(uint summoner) external view returns (uint amount);
    function transferFrom(uint executor, uint from, uint to, uint amount) external returns (bool);

    // for tests
    function approve(uint from, uint spender, uint amount) external returns (bool);
    function claim(uint summoner) external;
}

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