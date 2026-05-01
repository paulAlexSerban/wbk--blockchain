import { Button } from "@radix-ui/themes";
import { Transaction } from "@mysten/sui/transactions";
import {
  useCurrentAccount,
  useSignAndExecuteTransaction,
  useSuiClient,
} from "@mysten/dapp-kit";
import { useQueryClient } from "@tanstack/react-query";
const MintHeroButton = () => {
  const { mutateAsync, isPending } = useSignAndExecuteTransaction();
  const suiClient = useSuiClient();
  const queryClient = useQueryClient();
  const currentAccount = useCurrentAccount();
  if (!currentAccount) {
    return null;
  }
  const handleMintHero = async () => {
    try {
      // Replace with your actual minting logic
      const tx = new Transaction();
      const hero = tx.moveCall({
        target:
          "0xc413c2e2c1ac0630f532941be972109eae5d6734e540f20109d75a59a1efea1e::hero::mint_hero",
      });

      tx.transferObjects([hero], currentAccount.address);

      const response = await mutateAsync({
        transaction: tx,
      });

      console.log("Minting hero with transaction:", tx);

      suiClient.waitForTransaction({
        digest: response.digest,
      });
      // refetch the owned objects query
      queryClient.refetchQueries({
        predicate: (query) =>
          query.queryKey[0] === "testnet" &&
          query.queryKey[1] === "getOwnedObjects",
      });
    } catch (error) {
      console.error("Error minting hero:", error);
    }
  };
  return (
    <Button onClick={handleMintHero} variant="classic" disabled={isPending}>
      {isPending ? "Minting Hero..." : "Mint Hero"}
    </Button>
  );
};

export default MintHeroButton;
