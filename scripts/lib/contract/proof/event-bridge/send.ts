export interface Send {
  sender: number; // Sender index
  value: bigint; // Amount of native to use as msg.value for sender call
}
