// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Presale is Ownable, ReentrancyGuard {
    mapping(uint256 => uint256) public pricePerStage; // 1 : seed 2 : private 3 : public
    mapping(uint256 => uint256) public bonusPerStage; // in percentage : 1 : seed 2 : private 3 : public
    mapping(uint256 => uint256) public maxCapPerStage;
    mapping(uint256 => uint256) public soldAmountPerStage;
    AggregatorV3Interface internal priceFeed;
    address public tokenAddress = 0xD2c0c5E1855aEa5bd9c63C27bd802434509B99b5;
    uint256 public period = 30 days;
    uint256 public startDate;
    uint8 public current_stage = 1;

    // fallback() external payable {
    //     buyWithBNB(msg.sender, msg.value);
    // }

    constructor() {
        pricePerStage[1] = 4 * 10 ** 15;//0.004$
        pricePerStage[2] = 8 * 10 ** 15;
        pricePerStage[3] = 15 * 10 ** 15;

        maxCapPerStage[1] = 70000000*10**18;
        maxCapPerStage[2] = 10000000*10**18;
        maxCapPerStage[3] = 100000000*10**18;

        // bonusPerStage[1] = 20;
        // bonusPerStage[2] = 10;
        // bonusPerStage[3] = 5;
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function startSale() external onlyOwner {
        startDate = block.timestamp;
    }

    // function buyWithBNB(address toAddr, uint256 bnbAmount) internal {
    // 	// require(cur_stage != 0, "sale not started");
    // 	require(current_stage != 4, "sale ended");
    // 	uint256 sendAmount = bnbAmount * 10 ** 18 / pricePerStage[current_stage];

    // 	IERC20(tokenAddress).transfer(msg.sender, sendAmount);
    // 	soldAmountPerStage[current_stage] += sendAmount;
    // }

    function getLastPrice() public returns (uint256) {
         /**
        * Network: BSC Testnet
        * Aggregator: BNB/USD
        * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        
        * Network: BSC mainnet
        * Aggregator: BNB/USD
        * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        */
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price);//decimal: test-9, main-8
    }

    function buyToken(uint256 buyAmount) external payable nonReentrant {
        // uint256 sendAmount = buyAmount*(100 + bonusPerStage[cur_stage])/100;
        uint256 bnbPriceShouldReceive;
        uint256 lastPrice = getLastPrice();
        require(current_stage != 4, "sale ended");
        if(buyAmount + soldAmountPerStage[current_stage] > maxCapPerStage[current_stage]) {
            require(current_stage + 1 != 4, "sale ended");
            uint prevAmount = maxCapPerStage[current_stage] - soldAmountPerStage[current_stage];
            uint prevStagePrice = ((prevAmount * pricePerStage[current_stage]) / lastPrice) / (10**9);
            uint afterAmount = buyAmount + soldAmountPerStage[current_stage] - maxCapPerStage[current_stage];
            uint afterStagePrice = ((afterAmount * pricePerStage[current_stage+1]) / lastPrice) / (10**9);
            bnbPriceShouldReceive = prevStagePrice + afterStagePrice;
            require(
                msg.value >= bnbPriceShouldReceive,
                "you should send exact bnb"
            );
            
            soldAmountPerStage[current_stage+1] += afterAmount;
            soldAmountPerStage[current_stage] = maxCapPerStage[current_stage];
            current_stage++;
        }
        else {
            require(
                msg.value >= ((buyAmount * pricePerStage[current_stage]) / lastPrice) / (10 ** 9),
                "you should send exact bnb"
            );
            soldAmountPerStage[current_stage] += buyAmount;
        }
        IERC20(tokenAddress).transfer(msg.sender, buyAmount);
        
    }

    function withdraw() external onlyOwner {
        payable(address(msg.sender)).transfer(address(this).balance);
    }

    function burnUnsoldTokens(address deadAddress) external onlyOwner {
        uint256 remainingTokenAmount = IERC20(tokenAddress).balanceOf(
            address(this)
        );
        IERC20(tokenAddress).transfer(deadAddress, remainingTokenAmount);
    }
}