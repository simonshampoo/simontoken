//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ClaimSimonToken is Ownable, Pausable {
    using SafeERC20 for IERC20;
    IERC20 public immutable simonToken;

    event ClaimStart(uint256 claimStartTime, uint256 claimDuration);
    event TokensClaimed(
        address indexed claimer,
        uint256 amount,
        uint256 timestamp
    );
    event TokensBurned(
        address indexed burner,
        uint256 amount,
        uint256 timestamp
    );

    ///@notice gets updated by a set amount whenever someone claims.
    uint256 totalClaimed;

    ///@notice indicates the claim start time and claim duration
    ///@dev assigned values in the startClaim() function
    uint256 claimDuration;
    uint256 claimStartTime;

    ///@notice mapping from addresses to amountClaimed
    ///@dev all users who claimed will have a non-zero value associated with their address (obviously)
    mapping(address => uint256) amountClaimed;

    constructor(address _simonTokenAddress) {
        require(
            _simonTokenAddress != address(0),
            "ClaimSimonToken: $IMON Token address cannot be the zero adddress."
        );
        simonToken = IERC20(_simonTokenAddress);
        _pause();
    }

    ///@notice starts the claim period
    ///@param _claimDuration how long the claim will last
    ///@dev only callable by owner after deployment of contract
    function startClaim(uint256 _claimDuration) external onlyOwner whenPaused {
        require(_claimDuration > 0, "Claim duration has to be longer than 0.");
        claimDuration = _claimDuration;
        claimStartTime = block.timestamp;

        _unpause();

        emit ClaimStart(claimStartTime, claimDuration);
    }

    ///@notice pauses the claim period
    ///@dev only callable by owner. presumably to end the claim period
    function pauseClaim() external onlyOwner {
        _pause();
    }

    ///@notice allows addresses to claim amountToClaim tokens during the claim phase
    ///@dev updates the mapping between addresses and their claimed value
    ///@dev also updates totalClaimed by the amount claimed by users
    function claimTokens() external payable whenNotPaused {
        require(
            block.timestamp >= claimStartTime &&
                block.timestamp < claimStartTime + claimDuration,
            "ClaimSimonToken: Claimable period finished."
        );
        require(
            amountClaimed[msg.sender] == 0,
            "ClaimSimonToken: You've already claimed your tokens."
        );
        require(
            msg.sender != address(0),
            "ClaimSimonToken: Claimer cannot be the zero address."
        );
        uint256 amount = (10000 * msg.value) / 10**18;

        amountClaimed[msg.sender] += amount;

        totalClaimed += amount;

        emit TokensClaimed(msg.sender, amount, block.timestamp);

        simonToken.safeTransfer(msg.sender, amount);
    }

    ///@notice allows users to burn their tokens
    ///@param _amount the amount of tokens they want to burn
    function burnTokens(uint256 _amount) external {
        require(
            _amount > 0,
            "ClaimSimonToken: You must burn at least one token."
        );

        emit TokensBurned(msg.sender, _amount, block.timestamp);
        simonToken.transferFrom(msg.sender, address(0), _amount);
    }

    ///@notice transfers all unclaimed simon tokens and Ether to the smart contract after the claim duration is done
    function claimUnclaimedTokens() external onlyOwner {
        require(
            block.timestamp > claimStartTime + claimDuration,
            "ClaimSimonToken: Claimable period not done yet."
        );

        uint256 balance = address(this).balance;
        if (balance > 0) {
            Address.sendValue(payable(owner()), balance);
        }

        simonToken.safeTransfer(owner(), simonToken.balanceOf(address(this)));
    }
}
