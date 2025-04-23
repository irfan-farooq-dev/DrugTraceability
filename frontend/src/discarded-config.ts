interface AppConfig {
  blockchainNetwork: string;
  contractAddress: string;
  infuraId?: string;
  goerliUrl?: string;
}

const config: AppConfig = {
  blockchainNetwork: process.env.REACT_APP_BLOCKCHAIN_NETWORK || '',
  contractAddress: process.env.REACT_APP_CONTRACT_ADDRESS || '',
  infuraId: process.env.REACT_APP_INFURA_ID,
  goerliUrl: process.env.REACT_APP_GOERLI_URL
};

export default config;