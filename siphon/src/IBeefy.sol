// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "src/IERC20.sol";

/**
 * @dev Implementation of a vault to deposit funds for yield optimizing.
 * This is the contract that receives funds and that users interface with.
 * The yield optimizing strategy itself is implemented in a separate 'Strategy.sol' contract.
 */
interface IBeefy is IERC20 {

    function want() external view returns (IERC20);

    /**
     * @dev Function for various UIs to display the current value of one of our yield tokens.
     * Returns an uint256 with 18 decimals of how much underlying asset one vault share represents.
     */
    function getPricePerFullShare() external view returns (uint256);

    /**
     * @dev A helper function to call deposit() with all the sender's funds.
     */
    function depositAll() external;

    /**
     * @dev The entrypoint of funds into the system. People deposit with this function
     * into the vault. The vault is then in charge of sending funds into the strategy.
     */
    function deposit(uint _amount) external;

    /**
     * @dev A helper function to call withdraw() with all the sender's funds.
     */
    function withdrawAll() external;

    /**
     * @dev Function to exit the system. The vault will withdraw the required tokens
     * from the strategy and pay up the token holder. A proportional number of IOU
     * tokens are burned in the process.
     */
    function withdraw(uint256 _shares) external;
}