// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

contract cryptoMillion {
	address private owner;
	uint256 private currentRound = 0;

	uint256 public ticketValue = 0.001 ether;
	mapping(uint256 => uint64) winners;

	mapping(uint256 => mapping(address => uint64[])) players;
	mapping(uint256 => mapping(uint64 => address payable[])) tickets;

	constructor() {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier unpackCheck(uint64 packed)
	{
		for (uint8 i = 0; i < 5; i++) {
			uint8 number = uint8(packed >> (i * 8)) & 0xff;
			require(number > 0 && number < 40);
		}
		_;
	}

	function changeTicketValue(uint256 value)
		onlyOwner
		public
	{
		ticketValue = value;
	}

	function buy(address payable _address, uint64 numbers)
		onlyOwner
		unpackCheck(numbers)
		public
		payable
	{
		require(msg.value >= ticketValue);
		players[currentRound][_address].push(numbers);
		tickets[currentRound][numbers].push(_address);
	}

	function end(uint64 numbers)
		onlyOwner
		unpackCheck(numbers)
		public
	{
		winners[currentRound] = numbers;
		address payable[] memory addresses = tickets[currentRound][numbers];
		uint256 amount = (address(this).balance * 60 / 100) / addresses.length;
		for (uint8 i = 0; i < addresses.length; i++) {
			addresses[i].transfer(amount);
		}
		currentRound++;
	}

	function getBalance()
		public
		view
		returns (uint256)
	{
		return address(this).balance;
	}

	function getTicektsValue()
		public
		view
		returns (uint256)
	{
		return ticketValue;
	}

	function lastWinners()
		public
		view
		returns (uint64)
	{
		return winners[currentRound - 1];
	}
}
