const AWS = require('aws-sdk');
const s3 = new AWS.S3();
const zlib = require('zlib');

exports.handler = async (event) => {
    // Process each log event
    for (const record of event.awslogs.data) {
        const payload = Buffer.from(record, 'base64');
        const decompressed = await new Promise((resolve, reject) => {
            zlib.gunzip(payload, (err, result) => {
                if (err) reject(err);
                else resolve(result);
            });
        });
        
        const data = JSON.parse(decompressed.toString());
        
        // Upload to S3
        const params = {
            Bucket: process.env.S3_BUCKET,
            Key: `cloudwatch-logs/${data.logGroup}/${data.logStream}/${data.logEvents[0].id}.json`,
            Body: JSON.stringify(data.logEvents),
            ContentType: 'application/json'
        };
        
        await s3.putObject(params).promise();
    }
    
    return { status: 'Processed logs' };
};