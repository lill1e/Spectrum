(() => {
    function displayInventoryNotification(type, itemType, name, quantity) {
        let notif = ""

        if (type == 1) {
            notif += "+"
        } else {
            notif += "-"
        }

        if (itemType == 3) {
            notif += `${name} Ammo (${quantity} Rounds)`
        }
        else if (itemType == 1) {
            notif += quantity + " " + name
        }
        else {
            notif += " " + name
        }

        let elem = $("<div>" + notif + "</div>")
        $("#inventory_notifications").append(elem)

        $(elem)
            .delay(3000)
            .fadeOut(1000, () => {
                elem.remove()
            })
    }

    window.onData = (data) => {
        if (data.action === "notification") {
            displayInventoryNotification(data.type, data.itemType, data.item, data.quantity);
        }
    };

    window.onload = function(e) {
        window.addEventListener("message", (event) => {
            onData(event.data);
        });
    };
})();
