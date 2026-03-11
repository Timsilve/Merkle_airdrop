// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    // some list of addresss
    // allow somwone to claim tokens

    error MerkleAirdrop__InvalidProof();

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    event claim(address account, uint256 amount);

    constructor(bytes32 merkleRoots, IERC20 airdropToken) {
        i_merkleRoot = merkleRoots;
        i_airdropToken = airdropToken;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        // calculate using the amount and account, the hash --> the leaf node
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        emit claim(account, amount);
        i_airdropToken.transfer(account, amount);
    }
}
