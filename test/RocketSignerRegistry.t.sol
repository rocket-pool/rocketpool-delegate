// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RocketSignerRegistry} from "../src/RocketSignerRegistry.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract RocketSignerRegistryTest is Test {
    RocketSignerRegistry public registry;

    function setUp() public {
        registry = new RocketSignerRegistry();
    }

    function setSigningDelegate(address node, uint256 signerKey) internal {
        address signer = vm.addr(signerKey);
        address inUseNode = registry.signerToNode(signer);
        address existingSigner = registry.nodeToSigner(node);
        bool inUse = inUseNode != address(0);

        // Construct a valid signature for this request
        (uint8 v, bytes32 r, bytes32 s) = sign(signerKey, node);

        vm.prank(node);

        if (node == signer) {
            vm.expectRevert("Cannot set to self");
        } else if (inUse) {
            vm.expectRevert("Signer address already in use");
        }

        // Attempt to set
        registry.setSigningDelegate(signer, v, r, s);

        if (node == signer || inUse) {
            return;
        }

        // Check both forward and reverse mapping
        if (!inUse) {
            assertEq(registry.signerToNode(signer), node);
            assertEq(registry.nodeToSigner(node), signer);
        }

        // Check previous reverse mapping was cleared
        if (existingSigner != address(0)) {
            assertEq(registry.signerToNode(existingSigner), address(0));
        }
    }

    function clearSigningDelegate(address node) internal {
        address existingSigner = registry.nodeToSigner(node);
        bool exists = existingSigner != address(0);

        vm.prank(node);

        if (!exists) {
            vm.expectRevert("No signer set");
        }

        registry.clearSigningDelegate();

        if (exists) {
            // Check both forward and reverse mapping were cleared
            assertEq(registry.signerToNode(existingSigner), address(0));
            assertEq(registry.nodeToSigner(node), address(0));
        }
    }

    function sign(uint256 signerKey, address node) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        return vm.sign(signerKey, getSignatureDigest(node));
    }

    function getSignatureDigest(address node) internal view returns(bytes32) {
        bytes memory message = abi.encodePacked(Strings.toHexString(node), " may delegate to me for Rocket Pool governance");
        bytes memory prefixedMessage = abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(message.length), message);
        return keccak256(prefixedMessage);
    }

    function test_Set() public {
        setSigningDelegate(vm.addr(1), 2);
    }

    function test_Override() public {
        setSigningDelegate(vm.addr(1), 2);
        setSigningDelegate(vm.addr(1), 3);
    }

    function test_SetInUse() public {
        setSigningDelegate(vm.addr(1), 2);
        setSigningDelegate(vm.addr(3), 2);
    }

    function test_Clear() public {
        setSigningDelegate(vm.addr(1), 2);
        clearSigningDelegate(vm.addr(1));
    }

    function test_SetAfterClear() public {
        setSigningDelegate(vm.addr(1), 2);
        clearSigningDelegate(vm.addr(1));
        setSigningDelegate(vm.addr(1), 2);
    }

    function test_SetToSelf() public {
        setSigningDelegate(vm.addr(1), 1);
    }

    function test_ClearNonExisting() public {
        clearSigningDelegate(vm.addr(1));
    }

    function test_InvalidSignature() public {
        address node = vm.addr(1);
        address signer = vm.addr(2);

        // Sign with account 3 instead of 2
        (uint8 v, bytes32 r, bytes32 s) = sign(3, node);

        vm.prank(node);
        vm.expectRevert("Invalid signature");
        registry.setSigningDelegate(signer, v, r, s);
    }
}
