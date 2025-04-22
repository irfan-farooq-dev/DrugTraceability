// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import "./Types.sol";

contract ProductsContract {
    Types.Product[] private products;
    mapping(string => Types.Product) private productMap;
    mapping(address => string[]) private userLinkedProducts;
    mapping(string => Types.ProductHistory) private productHistory;

    event NewProduct(
        string name,
        string manufacturerName,
        string scientificName,
        string barcodeId,
        uint256 manDateEpoch,
        uint256 expDateEpoch
    );

    event ProductOwnershipTransfer(
        string name,
        string manufacturerName,
        string scientificName,
        string barcodeId,
        string buyerName,
        string buyerEmail
    );

    function addProduct(
        Types.Product memory product_,
        uint256 currentTime
    ) external {
        require(
            product_.manufacturer == msg.sender,
            "Only manufacturer can add"
        );
        require(!_productExists(product_.barcodeId), "Product already exists");

        products.push(product_);
        productMap[product_.barcodeId] = product_;
        userLinkedProducts[msg.sender].push(product_.barcodeId);
        productHistory[product_.barcodeId].manufacturer = Types.UserHistory({
            id_: msg.sender,
            date: currentTime
        });

        emit NewProduct(
            product_.name,
            product_.manufacturerName,
            product_.scientificName,
            product_.barcodeId,
            product_.manDateEpoch,
            product_.expDateEpoch
        );
    }

    function getAllProducts() external view returns (Types.Product[] memory) {
        return products;
    }

    function getUserProducts(
        address user
    ) external view returns (Types.Product[] memory) {
        string[] memory ids = userLinkedProducts[user];
        Types.Product[] memory userProducts = new Types.Product[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            userProducts[i] = productMap[ids[i]];
        }

        return userProducts;
    }

    function getProductDetails(
        string memory barcodeId
    )
        external
        view
        returns (Types.Product memory, Types.ProductHistory memory)
    {
        return (productMap[barcodeId], productHistory[barcodeId]);
    }

    function transferProduct(
        address buyer,
        string memory barcodeId,
        Types.UserDetails memory buyerDetails,
        uint256 currentTime
    ) external {
        require(_productExists(barcodeId), "Product does not exist");

        Types.Product memory prod = productMap[barcodeId];
        Types.UserHistory memory history = Types.UserHistory({
            id_: buyer,
            date: currentTime
        });

        if (buyerDetails.role == Types.UserRole.Supplier) {
            productHistory[barcodeId].supplier = history;
        } else if (buyerDetails.role == Types.UserRole.Vendor) {
            productHistory[barcodeId].vendor = history;
        } else if (buyerDetails.role == Types.UserRole.Customer) {
            productHistory[barcodeId].customers.push(history);
        } else {
            revert("Invalid buyer role");
        }

        _updateOwnership(msg.sender, buyer, barcodeId);

        emit ProductOwnershipTransfer(
            prod.name,
            prod.manufacturerName,
            prod.scientificName,
            prod.barcodeId,
            buyerDetails.name,
            buyerDetails.email
        );
    }

    function _updateOwnership(
        address from,
        address to,
        string memory barcodeId
    ) internal {
        userLinkedProducts[to].push(barcodeId);

        string[] storage fromList = userLinkedProducts[from];
        for (uint256 i = 0; i < fromList.length; i++) {
            if (_compareStrings(fromList[i], barcodeId)) {
                fromList[i] = fromList[fromList.length - 1];
                fromList.pop();
                break;
            }
        }
    }

    function _compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function _productExists(string memory id) internal view returns (bool) {
        return !_compareStrings(productMap[id].barcodeId, "");
    }
}
