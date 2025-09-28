module guestbook::guestbook ;

// Constant defining the maximum allowed length for a message (280 characters, like Twitter)
const MAX_MESSAGE_LENGTH: u64 = 280;

// Message struct represents a single guestbook entry
// 'store' ability means this struct can be stored inside other structs
public struct Message has store {
    content: vector<u8>,  // The actual message content as bytes
    author: address,      // The address of who wrote the message
}

// Guestbook struct represents the main guestbook object
// 'key' ability means this can be owned and transferred between addresses
public struct Guestbook has key {
    id: object::UID,              // Unique identifier required for all Sui objects
    messages: vector<Message>,    // Dynamic array storing all messages
    no_of_messages: u64,         // Counter tracking total number of messages
}

// Initialization function called once when the module is published
// Creates a new guestbook and makes it a shared object that anyone can interact with
fun init(ctx: &mut TxContext) {
    // Create a new guestbook instance
    let guestbook = Guestbook {
        id: object::new(ctx),              // Generate unique ID using transaction context
        messages: vector::empty<Message>(), // Start with empty message list
        no_of_messages: 0,                 // Start counter at zero
    };
    // Make the guestbook a shared object so multiple users can read/write to it
    sui::transfer::share_object(guestbook);
}

// Public function to add a message to the guestbook
// Takes a pre-created message and adds it to the guestbook's message list
public fun post_message(message: Message, guestbook: &mut Guestbook) {
    // Add the message to the end of the messages vector
    vector::push_back(&mut guestbook.messages, message);
    // Increment the message counter
    guestbook.no_of_messages = guestbook.no_of_messages + 1;
}

// Public function to create a new message with validation
// Returns a Message struct that can then be posted to the guestbook
public fun create_message(content: vector<u8>, ctx: &mut TxContext): Message {
    // Validate message length doesn't exceed maximum (will abort transaction if it does)
    assert!(content.length() <= MAX_MESSAGE_LENGTH, 1);
    // Get the address of the transaction sender
    let sender: address = ctx.sender();
    // Create and return a new Message struct
    Message { content, author: sender }
}