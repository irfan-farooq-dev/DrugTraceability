// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import "./Types.sol";

/**
 * @title Users
 * @dev Manages user accounts and their hierarchical relationships in the supply chain
 */
contract Users {
    mapping(address => Types.UserDetails) internal users;

    mapping(address => Types.UserDetails[]) internal manufacturerSuppliersList;
    mapping(address => Types.UserDetails[]) internal supplierVendorsList;
    mapping(address => Types.UserDetails[]) internal vendorCustomersList;

    event NewUser(string name, string email, Types.UserRole role);
    event LostUser(string name, string email, Types.UserRole role);

    // Adds a new user to the registry
    function add(Types.UserDetails memory user) internal {
        require(user.id_ != address(0), "Invalid user address");
        require(
            !has(user.role, user.id_),
            "User with this role already exists"
        );
        users[user.id_] = user;
        emit NewUser(user.name, user.email, user.role);
    }

    // Adds a party to the corresponding list of the logged-in user
    function addparty(
        Types.UserDetails memory user,
        address myAccount
    ) internal {
        require(myAccount != address(0), "Invalid caller");
        require(user.id_ != address(0), "Invalid user address");

        Types.UserRole myRole = get(myAccount).role;

        if (
            myRole == Types.UserRole.Manufacturer &&
            user.role == Types.UserRole.Supplier
        ) {
            manufacturerSuppliersList[myAccount].push(user);
            add(user);
        } else if (
            myRole == Types.UserRole.Supplier &&
            user.role == Types.UserRole.Vendor
        ) {
            supplierVendorsList[myAccount].push(user);
            add(user);
        } else if (
            myRole == Types.UserRole.Vendor &&
            user.role == Types.UserRole.Customer
        ) {
            vendorCustomersList[myAccount].push(user);
            add(user);
        } else {
            revert("Not a valid party relationship");
        }
    }

    // Returns the user's downstream party list
    function getMyPartyList(
        address id_
    ) internal view returns (Types.UserDetails[] memory usersList_) {
        require(id_ != address(0), "Empty address");
        Types.UserRole role = get(id_).role;

        if (role == Types.UserRole.Manufacturer) {
            return manufacturerSuppliersList[id_];
        } else if (role == Types.UserRole.Supplier) {
            return supplierVendorsList[id_];
        } else if (role == Types.UserRole.Vendor) {
            return vendorCustomersList[id_];
        } else {
            revert("Customers don't have parties");
        }
    }

    // Returns full user details
    function getPartyDetails(
        address id_
    ) internal view returns (Types.UserDetails memory) {
        require(id_ != address(0), "Empty address");
        return get(id_);
    }

    // Internal user getter
    function get(
        address account
    ) internal view returns (Types.UserDetails memory) {
        require(account != address(0), "Empty account address");
        return users[account];
    }

    // Removes a user by role
    function remove(Types.UserRole role, address account) internal {
        require(account != address(0), "Invalid address");
        require(has(role, account), "No such user with role");
        string memory name_ = users[account].name;
        string memory email_ = users[account].email;
        delete users[account];
        emit LostUser(name_, email_, role);
    }

    // Checks whether user is registered
    function isPartyExists(address account) internal view returns (bool) {
        return account != address(0) && users[account].id_ != address(0);
    }

    // Checks if a specific address has a specific role
    function has(
        Types.UserRole role,
        address account
    ) internal view returns (bool) {
        return
            account != address(0) &&
            users[account].id_ != address(0) &&
            users[account].role == role;
    }

    // Only manufacturers can call functions guarded by this modifier
    modifier onlyManufacturer() {
        require(msg.sender != address(0), "Empty sender");
        require(users[msg.sender].id_ != address(0), "Unregistered sender");
        require(
            users[msg.sender].role == Types.UserRole.Manufacturer,
            "Not a manufacturer"
        );
        _;
    }
}
