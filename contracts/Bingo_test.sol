// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./Bingo.sol";

contract BingoTest is Bingo {
    constructor(address _feeAddress) Bingo(_feeAddress){}

    function addNumbersToRound(uint8[] memory nums) external onlyOwner() {
        Round storage r = rounds[rounds.length-1];
        for (uint256 i = 0; i < nums.length; i++) {
            r.numbers[nums[i]] = true;
        }
    }

    function addPlayerBoard(uint256 forRound, uint8[24] memory nums) external onlyOwner() returns(Board memory b) {
        b.numbers = nums;
        b.forRounds = forRound;
        playerBoards[rounds.length-1][msg.sender] = b;
    }
}