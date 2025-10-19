// Redis Configuration
const redis = require('redis');

let redisClient;

const connectRedis = async () => {
  try {
    const redisURL = process.env.REDIS_URL || 'redis://localhost:6379';
    
    redisClient = redis.createClient({
      url: redisURL,
      retry_strategy: (options) => {
        if (options.error && options.error.code === 'ECONNREFUSED') {
          return new Error('Redis server refused connection');
        }
        if (options.total_retry_time > 1000 * 60 * 60) {
          return new Error('Retry time exhausted');
        }
        if (options.attempt > 10) {
          return undefined;
        }
        return Math.min(options.attempt * 100, 3000);
      }
    });
    
    redisClient.on('error', (err) => {
      console.error('❌ Redis Client Error:', err);
    });
    
    redisClient.on('connect', () => {
      console.log('📊 Redis Connected');
    });
    
    redisClient.on('ready', () => {
      console.log('✅ Redis Ready');
    });
    
    redisClient.on('end', () => {
      console.log('⚠️ Redis Connection Ended');
    });
    
    await redisClient.connect();
    
  } catch (error) {
    console.error('❌ Redis connection failed:', error);
    // Don't exit process for Redis connection failure
    // App can still work without Redis (with reduced functionality)
  }
};

const getRedisClient = () => {
  return redisClient;
};

module.exports = { connectRedis, getRedisClient };
