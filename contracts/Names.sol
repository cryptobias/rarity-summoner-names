// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Rarity.sol";
import "./RarityGold.sol";

contract Names {
    Rarity public rarity = Rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    RarityGold public rarityGold = RarityGold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2);

    mapping(uint => string) public names;

    function setName(uint summoner, string memory name) external {
        require(msg.sender == rarity.ownerOf(summoner), "only the owner can set the name of a summoner");
        names[summoner] = name;
    }
}