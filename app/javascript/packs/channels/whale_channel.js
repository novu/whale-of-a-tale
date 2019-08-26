import consumer from "./consumer"

let callback; // declaring a variable that will hold a function later

const whale = consumer.subscriptions.create({ channel: "WhaleChannel" }, {
  received(data) {
    if (callback) callback.call(null, data);
  }
})

// Sending a message: "perform" method calls a respective Ruby method
// defined in whale_channel.rb. That's your bridge between JS and Ruby!
const fly = () => whale.perform("fly");
const swim = () => whale.perform("swim");

// Getting a message: this callback will be invoked once we receive
// something over WhaleChannel
const setCallback = fn => {
  callback = fn;
};

export { fly, swim, setCallback };
