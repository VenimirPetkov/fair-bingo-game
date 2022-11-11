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

    function addPlayerBoard(uint256 _tillRound, uint8[24] memory nums) external onlyOwner() returns(Board memory b) {
        b.numbers = nums;
        b.tillRound = _tillRound;
        playerBoards[_tillRound][msg.sender] = b;
    }

    function bingoTest(uint checkIndex, uint round) external {
        Board memory b = playerBoards[round][msg.sender];
        require(b.tillRound >= rounds.length,"Bingo::bingo:no ticket found");
        bool hasBingo = _checkBingo(checkIndex, b);
        require(hasBingo, "no bingo");
        bool[255] memory nums;
        Round memory r = Round(block.timestamp, nums);
        rounds.push(r);
    }
}