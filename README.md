# Rarity Summoner Names

⚠ __The contract is not audited. Use at your own and your summoners risk!__ ⚠

Are you and your summoners/adventurers tired of them just being a number? - Not anymore.

With this contract, deployed at [0x1e035b7b0675Ef0114dd1659524d22c21e32D4da](https://ftmscan.com/address/0x1e035b7b0675Ef0114dd1659524d22c21e32D4da#writeContract), you are able to give your trusty adventurers a nifty name.

Just call the `setName` method with their ID (urgh) and the name you'd like them to have.

It is also possible to rename an adventurer, but this comes with a price (of gold). So you will have to make sure to `claim` your gold on the [Rarity Gold contract](https://ftmscan.com/address/0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2#writeContract) and `approve` the Names contract's burn summoner (`695026`) to spent the `nextRenameCost` amount first.

```
// first name is free
names.setName(123, "Harry");

// rename costs exponentially increase per summoner
rarityGold.claim(123);
rarityGold.approve(123, 695026, 100e18);
names.setName(123, "Ron");
```