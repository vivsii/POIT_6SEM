const redis = require('redis');

async function runPubSub() {
    const subscriber = redis.createClient({ url: 'redis://vivsi:vivsi@localhost:6380' });
    const publisher = redis.createClient({ url: 'redis://vivsi:vivsi@localhost:6380' });

    subscriber.on('error', (err) => console.error('Subscriber error:', err));
    publisher.on('error', (err) => console.error('Publisher error:', err));

    await subscriber.connect();
    await publisher.connect();

    await subscriber.subscribe('news', (message) => {
        console.log(`Получено сообщение: ${message}`);
    });

    const messages = ['Привет', '17 лаба', 'Redis изи'];
    let index = 0;

    const interval = setInterval(async () => {
        if (index < messages.length) {
            const msg = messages[index];
            await publisher.publish('news', msg);
            console.log(`Отправлено: ${msg}`);
            index++;
        } else {
            clearInterval(interval);
            setTimeout(async () => {
                await subscriber.quit();
                await publisher.quit();
                console.log('Завершено');
            }, 1000);
        }
    }, 1000);
}

runPubSub();
