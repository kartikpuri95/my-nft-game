// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyNFTGame is ERC721 {
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }
    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    CharacterAttributes[] defaultCharacters;
    BigBoss public bigBoss;
    // mapping of token id and CharacterAttributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        string memory bossName, // These new variables would be passed in via run.js or deploy.js.
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    ) ERC721("Mario Verse", "MRV") {
        console.log("This is my gaming contract - Kartik is turning pro now");

        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i]
                })
            );
            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });
        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );
        _tokenIds.increment();
    }

    function mintCharacter(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });
        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
    }

    function attackBoss() external {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );
        //   make sure the player has more than 0hp
        require(player.hp > 0, "error player has low hp");
        // make sure the boss has more than 0hp;
        require(bigBoss.hp > 0, "error big boss has no hp");
        // Allow player to attack boss
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }
        // allow boss to attack plater
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }
        // Console for ease.
        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);
    }
    function checkIFUserHasNFT() public view returns (CharacterAttributes memory){
        uint userNFTTokenId= nftHolders[msg.sender];
        if (userNFTTokenId > 0){
            return nftHolderAttributes[userNFTTokenId];
        }
        else {
            CharacterAttributes memory emptystruct;
            return emptystruct;
        }
    }
    function getAllDefaultCharacters() public view returns(CharacterAttributes[] memory){
          return defaultCharacters;

    }
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}