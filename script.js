const messageInput = document.getElementById("messageInput");
const sendButton = document.getElementById("sendButton");
const messageArea = document.querySelector(".message-area");

function getTime() {
    const now = new Date();

    return now.toLocaleTimeString("ru-RU", {
        hour: "2-digit",
        minute: "2-digit"
    });
}

function sendMessage() {
    const text = messageInput.value.trim();

    if (text === "") {
        return;
    }

    // Удаляем приветствие
    const welcome = document.querySelector(".welcome");

    if (welcome) {
        welcome.remove();
    }

    // Создаём контейнер сообщения
    const messageWrapper = document.createElement("div");
    messageWrapper.classList.add("message-wrapper");

    // Само сообщение
    const message = document.createElement("div");
    message.classList.add("my-message");

    const textElement = document.createElement("span");
    textElement.classList.add("message-text");
    textElement.textContent = text;

    // Время
    const time = document.createElement("span");
    time.classList.add("message-time");
    time.textContent = getTime();

    // Кнопка меню
    const menuButton = document.createElement("button");
    menuButton.classList.add("message-menu");
    menuButton.textContent = "⋮";

    // Меню сообщения
    const menu = document.createElement("div");
    menu.classList.add("message-options");

    const editButton = document.createElement("button");
    editButton.textContent = "Изменить";

    const deleteButton = document.createElement("button");
    deleteButton.textContent = "Удалить";

    // Редактирование
    editButton.addEventListener("click", () => {
        const newText = prompt("Изменить сообщение:", textElement.textContent);

        if (newText !== null && newText.trim() !== "") {
            textElement.textContent = newText.trim();
        }

        menu.classList.remove("show");
    });

    // Удаление
    deleteButton.addEventListener("click", () => {
        messageWrapper.remove();
    });

    // Открытие меню
    menuButton.addEventListener("click", (event) => {
        event.stopPropagation();
        menu.classList.toggle("show");
    });

    // Собираем меню
    menu.appendChild(editButton);
    menu.appendChild(deleteButton);

    // Собираем сообщение
    message.appendChild(textElement);
    message.appendChild(time);
    message.appendChild(menuButton);
    message.appendChild(menu);

    messageWrapper.appendChild(message);

    messageArea.appendChild(messageWrapper);

    // Очищаем поле
    messageInput.value = "";

    // Прокручиваем вниз
    messageArea.scrollTop = messageArea.scrollHeight;
}

// Отправка кнопкой
sendButton.addEventListener("click", sendMessage);

// Отправка Enter
messageInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
        sendMessage();
    }
});

// Закрытие меню при клике вне сообщения
document.addEventListener("click", () => {
    document.querySelectorAll(".message-options").forEach(menu => {
        menu.classList.remove("show");
    });
});
// Показываем имя пользователя
const savedName = localStorage.getItem("kleivy_name");

if (savedName) {
    const userName = document.getElementById("userName");
    const chatUserName = document.getElementById("chatUserName");

    if (userName) {
        userName.textContent = savedName;
    }

    if (chatUserName) {
        chatUserName.textContent = savedName;
    }
}