import { fly, swim, setCallback } from "../channels/whale_channel";

const initialize = () => {
  const whale = document.querySelector(".whale");
  const sky = document.querySelector(".sky");
  const ocean = document.querySelector(".ocean");

  if(sky) {
    sky.addEventListener("click", event => {
      event.preventDefault();
      if(!sky.querySelector('.whale')) {
        fly();
      }
    })
  }

  if(ocean) {
    ocean.addEventListener("click", event => {
      event.preventDefault();
      if(!ocean.querySelector('.whale')) {
        swim();
      }
    })
  }

  setCallback(data => {
    if(data === 'swim') {
      ocean.appendChild(whale)
    } else if (data === 'fly') {
      sky.appendChild(whale)
    }
  })
};

export { initialize };
