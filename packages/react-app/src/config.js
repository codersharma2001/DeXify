import { Goerli } from "@usedapp/core";

export const ROUTER_ADDRESS = "0x4ef5b1E3dA5573466Fb1724D2Fca95290119B664";

export const DAPP_CONFIG = {
  readOnlyChainId: Goerli.chainId,
  readOnlyUrls: {
    [Goerli.chainId]: "https://eth-goerli.g.alchemy.com/v2/aYicO41gEJgoFHNiuKrEHsxtkfMw_fsm",
  },
};
