// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import "./Types.sol";
import "./UsersContract.sol";
import "./ProductsContract.sol";

/**
 * @title SupplyChainRouter
 * @dev Central contract that delegates user and product logic to modular contracts
 */
contract SupplyChainRouter {
    UsersContract private usersContract;
    ProductsContract private productsContract;

    constructor(address _usersAddress, address _productsAddress) {
        usersContract = UsersContract(_usersAddress);
        productsContract = ProductsContract(_productsAddress);
    }

    modifier onlyManufacturer() {
        require(
            usersContract.has(Types.UserRole.Manufacturer, msg.sender),
            "Only manufacturer allowed"
        );
        _;
    }

    // USER MANAGEMENT
    function registerUser(Types.UserDetails memory user) public {
        usersContract.addParty(user, msg.sender);
    }

    function getUser(
        address userId
    ) public view returns (Types.UserDetails memory) {
        return usersContract.get(userId);
    }

    function getMyDetails() public view returns (Types.UserDetails memory) {
        return usersContract.get(msg.sender);
    }

    function getMyParties() public view returns (Types.UserDetails[] memory) {
        return usersContract.getMyPartyList(msg.sender);
    }

    // PRODUCT MANAGEMENT
    function addProduct(
        Types.Product memory newProduct,
        uint256 currentTime
    ) public onlyManufacturer {
        productsContract.addProduct(newProduct, currentTime);
    }

    function getAllProducts() public view returns (Types.Product[] memory) {
        return productsContract.getAllProducts();
    }

    function getMyProducts() public view returns (Types.Product[] memory) {
        return productsContract.getUserProducts(msg.sender);
    }

    function getProductDetails(
        string memory barcodeId
    ) public view returns (Types.Product memory, Types.ProductHistory memory) {
        return productsContract.getProductDetails(barcodeId);
    }

    function transferProduct(
        address buyerId,
        string memory barcodeId,
        uint256 currentTime
    ) public {
        require(usersContract.isPartyExists(buyerId), "Buyer not found");
        Types.UserDetails memory buyer = usersContract.get(buyerId);
        productsContract.transferProduct(
            buyerId,
            barcodeId,
            buyer,
            currentTime
        );
    }
}
