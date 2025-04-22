// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import "./Types.sol";

contract UsersContract {
    mapping(address => Types.UserDetails) private users;

    mapping(address => Types.UserDetails[]) private manufacturerSuppliersList;
    mapping(address => Types.UserDetails[]) private supplierVendorsList;
    mapping(address => Types.UserDetails[]) private vendorCustomersList;

    event NewUser(string name, string email, Types.UserRole role);
    event LostUser(string name, string email, Types.UserRole role);

    function add(Types.UserDetails memory user) external {
        require(user.id_ != address(0), "Invalid user address");
        require(
            !has(user.role, user.id_),
            "User with this role already exists"
        );
        users[user.id_] = user;
        emit NewUser(user.name, user.email, user.role);
    }

    // function registerUser(Types.UserDetails memory user) public {
    //     add(user);
    // }

    function addParty(Types.UserDetails memory user, address caller) external {
        require(caller != address(0), "Invalid caller");
        require(user.id_ != address(0), "Invalid user address");

        Types.UserRole myRole = get(caller).role;

        if (
            myRole == Types.UserRole.Manufacturer &&
            user.role == Types.UserRole.Supplier
        ) {
            manufacturerSuppliersList[caller].push(user);
        } else if (
            myRole == Types.UserRole.Supplier &&
            user.role == Types.UserRole.Vendor
        ) {
            supplierVendorsList[caller].push(user);
        } else if (
            myRole == Types.UserRole.Vendor &&
            user.role == Types.UserRole.Customer
        ) {
            vendorCustomersList[caller].push(user);
        } else {
            revert("Invalid party relationship");
        }

        users[user.id_] = user;
        emit NewUser(user.name, user.email, user.role);
    }

    function getMyPartyList(
        address id_
    ) external view returns (Types.UserDetails[] memory) {
        Types.UserRole role = users[id_].role;

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

    function get(address id_) public view returns (Types.UserDetails memory) {
        return users[id_];
    }

    function getPartyDetails(
        address id_
    ) external view returns (Types.UserDetails memory) {
        return users[id_];
    }

    function remove(Types.UserRole role, address account) external {
        require(account != address(0), "Invalid address");
        require(has(role, account), "No such user with role");
        string memory name_ = users[account].name;
        string memory email_ = users[account].email;
        delete users[account];
        emit LostUser(name_, email_, role);
    }

    function isPartyExists(address account) external view returns (bool) {
        return account != address(0) && users[account].id_ != address(0);
    }

    function has(
        Types.UserRole role,
        address account
    ) public view returns (bool) {
        return
            account != address(0) &&
            users[account].id_ != address(0) &&
            users[account].role == role;
    }
}
