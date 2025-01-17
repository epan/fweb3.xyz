// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface Game {
  function isWinner(address player) view external returns (bool);
}

contract Fweb3CommemorativeNFT is ERC721 {
  address private _gameAddress;

  constructor(
    string memory _name,
    string memory _symbol,
    address gameAddress
  ) ERC721("Fweb3 2022 Commemorative NFT", "FWEB3COMMEMORATIVENFT") {
    _gameAddress = gameAddress;
  }

  function isWinner(address player) view public returns (bool) {
    Game game = Game(_gameAddress);
    return game.isWinner(player);
  }

  function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function getBackgroundColor(uint256 tokenId) public pure returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(toString(tokenId))));
    bytes32 val = bytes32(rand);
    bytes memory hx = "0123456789ABCDEF";
    bytes memory str = new bytes(6);

    for (uint i = 0; i < 6; i++) {
      str[i] = hx[uint8(val[i]) & 0x0f];
    }

    return string(str);
  }

  function tokenURI(uint256 tokenId) override public pure returns (string memory) {
    string[4] memory parts;
    string memory backgroundColor = getBackgroundColor(tokenId);

    parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 512 512"><rect width="100%" height="100%" fill="#';
    parts[1] = backgroundColor;
    parts[2] = '"/>';
    parts[3] = '</svg>';

    string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));

    string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Fweb3 Trophy NFT", "description": "This NFT represents winning Fweb3 2022.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
    output = string(abi.encodePacked('data:application/json;base64,', json));

    return output;
  }

  function mint(uint256 tokenId) public {
    require(isWinner(msg.sender), "Not a winner");
    _safeMint(_msgSender(), tokenId);
  }
}

library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
