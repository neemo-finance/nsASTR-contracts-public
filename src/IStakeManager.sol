// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title StakeManager Interface
 * @notice Interface for the Stake Manager contract with detailed error messages and events.
 * @author Neemo.
 */
interface IStakeManager {
     /// @notice Status of withdraw orders.
    enum OrderStatus {
        Inactive,
        Active,
        Redeemed
    }

    /// @notice Status of batch.
    enum BatchStatus {
        Active,
        Unlocking,
        Finalized
    }

    /// @notice Thrown when authentication fails.
    error AuthenticationFailed();

    /// @notice Thrown when an action is paused.
    error ActionPaused();

    /// @notice Thrown when an input parameter is invalid.
    error InvalidInput();

    /// @notice Thrown when reprice fails
    error RepriceFailed(string reason);

    /// @notice Thrown when wrapped token deposits are inactive.
    error WrappedTokenDepositInactive();

    /// @notice Thrown when invalid data is sent in claim
    error TokenRedeemFailed(string _reason);

    /// @notice Thrown when a token deposit exceeds the cap.
    error DepositCapExceeded();

    /// @notice Thrown when the implementation is invalid.
    error InvalidImplementation();

    /// @notice Thrown when a token redemption fails due to zero amount.
    error InvalidRescueAmount();

    /// @notice Thrown when a token deposit fails due to invalid amount.
    error InvalidStakeAmount();

    /// @notice Thrown when there is insufficient liquidity in the pool
    error InsufficientLiquidity();

    /// @notice Thrown when there is insufficient balance in the user's account.
    error InsufficientBalance();

    /// @notice Thrown when unlocking period is not reached.
    error UnlockingPeriodNotReached();

    /// @notice Thrown when a withdraw request cannot be canceled.
    error CancelWithdrawFailed(string);

    /// @notice Thrown when a function is not yet implemented.
    error NotImplemented();

    /// @notice Thrown when the staking dApp cannot be set.
    error CannotSetStakingDapp();

    /// @notice Thrown when a transfer fails.
    /// @param to The address to which the transfer failed.
    /// @param amount The amount that failed to be transferred.
    error TransferFailed(address to, uint256 amount);

    /// @notice Emitted when tokens are rescued.
    /// @param _token The address of the token.
    /// @param amount The amount of tokens rescued.
    event LogRescueTokens(address indexed _token, uint256 amount);

    /// @notice Emitted when the treasury address is set.
    /// @param _oldTreasury The previous treasury address.
    /// @param _newTreasury The new treasury address.
    event LogSetTreasury(address _oldTreasury, address _newTreasury);

    /// @notice Emitted when a deposit is made.
    /// @param _recipient The address of the recipient.
    /// @param _amount The amount deposited.
    /// @param _lstAllocated The amount of lst allocated.
    event LogDeposit(address indexed _recipient, uint256 _amount, uint256 _lstAllocated);

    /// @notice Emitted when a user is referred by another address.
    /// @param _user The address of the user.
    /// @param _referredBy The address of the referrer.
    /// @param _amount The amount of tokens deposited by the user.
    event LogReferredBy(address indexed _user, address indexed _referredBy, uint256 _amount);

    /// @notice Emitted when the identifier is set.
    /// @param _identifier The new identifier.
    event LogSetIdentifier(uint8 _identifier);

    /// @notice Emitted when the deposit cap is set.
    /// @param _oldCap The previous deposit cap.
    /// @param _newCap The new deposit cap.
    event LogSetDepositCap(uint256 _oldCap, uint256 _newCap);

    /// @notice Emitted when tokens are locked.
    /// @param _amount The amount locked.
    event LogTokenLock(uint256 _amount);

    /// @notice Emitted when tokens are unlocked.
    /// @param _amount The amount unlocked.
    event LogTokenUnlock(uint256 _amount);

    /// @notice Emitted when locked tokens are unlocked.
    /// @param _amount The amount unlocked.
    event LogUnlockedLockedTokens(uint256 _amount);

    /// @notice Emitted when tokens are staked.
    /// @param _amount The amount staked.
    event LogTokenStake(uint256 _amount);

    /// @notice Emitted when tokens are unstaked.
    /// @param _amount The amount unstaked.
    event LogTokensUnstaked(uint256 _amount);

    /// @notice Emitted when tokens are redeemed.
    /// @param _sentTo The caller of the function.
    /// @param _batchId The ID of the batch.
    /// @param _lstUnstaked The amount of lst unstaked.
    /// @param _ASTRReceived The amount of ASTR received.
    event LogTokenClaimed(address _sentTo, uint256 _batchId, uint256 _lstUnstaked, uint256 _ASTRReceived);

    /// @notice Emitted when a withdraw request is canceled.
    /// @param _batchId The ID of the batch of the withdraw request.
    /// @param _user The user address.
    /// @param _lstUnstaked The amount of lst unstaked.
    event LogCancelRequestWithdraw(uint256 indexed _batchId, address indexed _user, uint256 _lstUnstaked);

    /// @notice Emitted when the exchange deviation is set.
    /// @param _decreaseLimit The decrease limit.
    /// @param _increaseLimit The increase limit.
    event LogSetExchangeDeviation(uint256 _decreaseLimit, uint256 _increaseLimit);

    /// @notice Emitted when a reward boost is made.
    /// @param _donator The address of the donator.
    /// @param donationAmount The amount of the donation.
    event LogRewardBoost(address indexed _donator, uint256 donationAmount);

    /// @notice Emitted when the staking dApp is set.
    /// @param newStakingDapp The new staking dApp address.
    event LogSetStakingDapp(address newStakingDapp);

    /// @notice Emitted when staking is activated or deactivated.
    /// @param isStakingActive Boolean indicating whether staking is active.
    event LogSetStakingActive(bool isStakingActive);

    /// @notice Emitted when the reward fee is set.
    /// @param _oldFee The previous reward fee.
    /// @param _newFee The new reward fee.
    event LogSetRewardFee(uint256 _oldFee, uint256 _newFee);

    /// @notice Emitted when the mint fee is set.
    /// @param _oldFee The previous mint fee.
    /// @param _newFee The new mint fee.
    event LogSetMintFee(uint256 _oldFee, uint256 _newFee);

    /// @notice Emitted when a withdraw request is made.
    /// @param _user The address of the user.
    /// @param _amount The amount requested to withdraw.
    /// @param _batchId The ID of the batch.
    event LogRequestWithdraw(address indexed _user, uint256 _amount, uint256 _batchId);

    /// @dev Struct holding staking state metadata.
    struct AssetStateMeta {
        uint256 totalAstarDeposit;
        uint256 totalAstarStaked;
        uint256 totalAstarPendingToStake;
        uint256 totalAstarPendingBonus;
        uint256 totalAstarRedeemable;
        uint256 totalLstSupply;
    }

    /// @notice Struct holding unstake request metadata.
    struct WithdrawRequestMeta {
        OrderStatus status;
        uint256 unstaked;
        uint256 received;
    }

    /// @notice Struct holding batch metadata.
    struct BatchMeta {
        uint256 lstWithdrawQueue;
        uint256 endingEra;
        uint256 finalExchangeRate;
        BatchStatus status;
    }

    /// @notice Struct holding era configuration.
    struct EraConfig {
        uint256 era;
        uint256 period;
        uint256 minStakeAmount;
    }

    /// @notice Rescue tokens.
    /// @param _token The address of the token to be rescued.
    /// @return rescuedAmount The amount of tokens rescued.
    function rescueTokens(address _token) external returns (uint256 rescuedAmount);

    /// @notice Set the deposit cap.
    /// @param _newCap The new deposit cap.
    function setDepositCap(uint256 _newCap) external;

    /// @notice Get the protocol configuration.
    /// @param _config The configuration key.
    /// @return The configuration value.
    function protocolConfig(bytes32 _config) external view returns (uint256);

    /// @notice Get the asset state.
    /// @return The asset state metadata.
    function getAssetState() external view returns (AssetStateMeta memory);

    /// @notice Get user withdraw requests.
    /// @param _user The address of the user.
    /// @param _batchId The ID of the batch.
    /// @return The withdraw request metadata.
    function getUserWithdrawRequests(address _user, uint256 _batchId) external view returns (WithdrawRequestMeta memory);

    /// @notice Set the treasury address.
    /// @param _newTreasury The new treasury address.
    function setTreasury(address payable _newTreasury) external;

    /// @notice Deposit native tokens and mint lst.
    /// @param _referredBy The address of the referrer.
    /// @return The amount of lst minted.
    function deposit(address _referredBy) external payable returns (uint256);

    /// @notice Request to withdraw lst.
    /// @param _lstAmount The amount of lst to withdraw.
    /// @return The ID of the batch.
    function requestWithdraw(uint256 _lstAmount) external returns (uint256);
}
}
