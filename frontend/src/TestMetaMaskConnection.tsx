import React, { useEffect, useState } from "react";
import { ethers } from "ethers";

declare let window: any;

const TestMetaMaskConnection = () => {
  const [account, setAccount] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const connectWallet = async () => {
    try {
      if (!window.ethereum) {
        setError("MetaMask not detected");
        return;
      }

      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      const addr = await signer.getAddress();

      setAccount(addr);
    } catch (err: any) {
      setError(err.message);
    }
  };

  useEffect(() => {
    connectWallet();
  }, []);

  return (
    <div style={{ padding: "2rem", fontFamily: "sans-serif" }}>
      <h2>MetaMask Connection Test</h2>
      {account ? (
        <p>✅ Connected Wallet: {account}</p>
      ) : error ? (
        <p style={{ color: "red" }}>❌ Error: {error}</p>
      ) : (
        <p>⏳ Connecting...</p>
      )}
    </div>
  );
};

export default TestMetaMaskConnection;
