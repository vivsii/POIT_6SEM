const redis = require('redis');
const { performance } = require('perf_hooks');

async function run() {
  const client = redis.createClient({ url: 'redis://localhost:6380' });

  client.on('error', (err) => {
    console.error('Redis error:', err);
  });
  await client.connect();
  console.log("Подключено к Redis");
  await client.set('incr', 0);

  // INCR 
  const t1 = performance.now();
  for (let i = 0; i < 10000; i++) {
    await client.incr('incr');
  }
  const t2 = performance.now();

  // DECR 
  const t3 = performance.now();
  for (let i = 0; i < 10000; i++) {
    await client.decr('incr');
  }
  const t4 = performance.now();
  await client.quit();
  console.log('\nРезультаты выполнения 10 000 операций INCR и DECR:\n');
  console.table([
    { Операция: 'incr("incr")', 'Время (мс)': (t2 - t1).toFixed(2) },
    { Операция: 'decr("incr")', 'Время (мс)': (t4 - t3).toFixed(2) },
  ]);
}
run();