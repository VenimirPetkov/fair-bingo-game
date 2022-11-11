// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./Ownable.sol";
import "../interfaces/IERC20.sol";

contract Bingo is Ownable {
    struct Board {
        uint8[24] numbers;
        uint256 tillRound;
    }

    struct Round {
        uint256 lastDraw;
        bool[255] numbers;
    }

    mapping(uint256 => mapping(address => Board)) internal playerBoards;

    Round[] internal rounds;
    uint256 private feeAmount;
    
    uint256 fees;

    uint256 private minJoin;

    uint256 private minDrawDuration;

    address immutable public feeAddress;

    constructor(address _feeAddress){
        feeAddress = _feeAddress;
        bool[255] memory nums;
        Round memory genesisRound = Round(block.timestamp, nums);
        rounds.push(genesisRound);
    }

    function buyBoard(uint256 _tillRound) external returns(Board memory b){
        require(playerBoards[rounds.length-1][msg.sender].tillRound < rounds.length,"Bingo::buyBoard:one board per round");
        require(IERC20(feeAddress).transferFrom(_msgSender(), address(this), feeAmount*_tillRound), "Bingo::buyBoard:fee payment failed");
        fees = fees + feeAmount;
        b.numbers = _generateBoardNumbers();
        b.tillRound = _tillRound;
        playerBoards[_tillRound][msg.sender] = b;
        //TODO emit Event
        return b;
    }

    function drawNumber() external onlyOwner() {
        Round storage r = rounds[rounds.length-1];
        require(r.lastDraw+minDrawDuration < block.timestamp, "Bingo::drawNumber:please await minimum draw duration");
        uint8 num = _generateRoundNumber();
        if(r.numbers[num] == false){
            r.numbers[num] = true;
        }
        r.lastDraw = block.timestamp;
        //TODO emit Event
    }
    /*
            6     7     8     9     10
       1 |--0--|--1--|--2--|--3--|--4--|
       2 |--5--|--6--|--7--|--8--|--9--|
       3 |-10--|-11--|     |-12--|-13--|
       4 |-14--|-15--|-16--|-17--|-18--|
       5 |-19--|-20--|-21--|-22--|-23--|

       diagonal from left 1,6 to rigth 5,10 = 11
       diagonal from right 5,6 to left 1,10 = 12

    */
    function bingo(uint checkIndex, uint round) external {
        Board memory b = playerBoards[round][msg.sender];
        require(b.tillRound >= rounds.length,"Bingo::bingo:no ticket found");
        bool hasBingo = _checkBingo(checkIndex, b);
        if(hasBingo){
            IERC20(feeAddress).transfer(_msgSender(), fees);
            bool[255] memory nums;
            Round memory r = Round(block.timestamp, nums);
            rounds.push(r);
        }
    }

    //***************************************************************** GETTERS ************************************************************** */

    function getBoardForRound(uint256 round, address player) public view returns(Board memory){
        return playerBoards[round][player];
    }

    function getRound(uint index) public view returns(Round memory){
        return rounds[index];
    }

    //***************************************************************** SETTERS ************************************************************** */

    function setMinJoin(uint256 _minJoin) external onlyOwner() {
        minJoin = _minJoin;
        //TODO emit Event
    }

    function setminDrawDuration(uint256 _minDrawDuration) external onlyOwner() {
        minDrawDuration = _minDrawDuration;
        //TODO emit Event
    }

    function setFeeAmount(uint256 _feeAmount) external onlyOwner() {
        feeAmount = _feeAmount;
        //TODO emit Event
    }

    //***************************************************************** INTERNAL ************************************************************** */
    function fakeRandom(bytes1 salt) internal view returns(uint8 _number){
		return uint8((uint8(salt)+uint160(msg.sender)+block.difficulty)%256);
    }

    function fakeRandomFromHash(bytes32 salt) internal view returns(uint8 _number){
		return uint8((uint(salt)+uint160(msg.sender)+block.difficulty)%256);
    }

    function _generateRoundNumber() internal view returns(uint8){
        bytes32 h = blockhash(block.number - 1);
        return fakeRandomFromHash(h);
    }

    function _generateBoardNumbers() internal view returns(uint8[24] memory numbers){
        bytes32 h = blockhash(block.number - 1);
        for (uint256 i = 0; i < numbers.length; i++) {
            uint8 num = fakeRandom(h[i]);
                numbers[i] = num;
        }
    }

    function _checkBingo(uint index, Board memory b) internal view returns(bool) {
        Round memory r = rounds[rounds.length-1];
        if(index == 3 || index == 8 || index == 11 || index == 12){
            uint[4] memory indexes;
            if (index == 3) {
                indexes = _fillShortRow(10);
            }else if (index == 8){
                indexes[0] = 2;
                indexes[1] = 7;
                indexes[2] = 16;
                indexes[3] = 21;
            } else if (index == 11){
                indexes[0] = 0;
                indexes[1] = 6;
                indexes[2] = 17;
                indexes[3] = 23;
            }else if (index == 12){
                indexes[0] = 4;
                indexes[1] = 8;
                indexes[2] = 15;
                indexes[3] = 19;
            }
            for (uint256 i = 0; i < indexes.length; i++) {
                if(r.numbers[b.numbers[indexes[i]]] == false){
                    return false;
                }
            }
        }else{
            uint[5] memory indexes;
            if (index == 1) {
                indexes = _fillFullRow(0);
            }else if(index == 2){
                indexes = _fillFullRow(5);
            }else if(index == 4){
                indexes = _fillFullRow(14);
            }else if(index == 5){
                indexes = _fillFullRow(19);
            }else if(index == 6){
                indexes = _fillFullColumn(0);
            }else if(index == 7){
                indexes = _fillFullColumn(1);
            }else if(index == 9){
                indexes = _fillFullColumn(3);
            }else if(index == 10){
                indexes = _fillFullColumn(4);
            }

            for (uint256 i = 0; i < 5; i++) {
                if(r.numbers[b.numbers[indexes[i]]] == false){
                    return false;
                }
            }  
        }
        return true; //risky move
    }

    function _fillShortRow(uint startIndex) internal pure returns(uint[4] memory indexes){
        indexes[0] = startIndex;
        indexes[1] = startIndex+1;
        indexes[2] = startIndex+2;
        indexes[3] = startIndex+3;
    }

    function _fillFullRow(uint startIndex) internal pure returns(uint[5] memory indexes){
        indexes[0] = startIndex;
        indexes[1] = startIndex+1;
        indexes[2] = startIndex+2;
        indexes[3] = startIndex+3;
        indexes[4] = startIndex+4;
    }

    function _fillFullColumn(uint startIndex) internal pure returns(uint[5] memory indexes){
        indexes[0] = startIndex;
        indexes[1] = startIndex+5;
        indexes[2] = startIndex+10;
        indexes[3] = startIndex+15;
        indexes[4] = startIndex+19;
    }
}