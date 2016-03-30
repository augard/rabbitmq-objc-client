@objc class ChannelSpy : NSObject, RMQChannel {
    var channelNumber: NSNumber
    var lastReceivedBasicConsumeBlock: ((RMQMessage) -> Void)?
    var lastReceivedFrameset: AMQFrameset?
    var queues: [String: RMQQueue] = [:]
    var stubbedMessageCount: AMQLong = AMQLong(0)
    var stubbedConsumerCount: AMQLong = AMQLong(0)
    var lastReceivedQueueDeclareOptions: AMQQueueDeclareOptions = []

    init(_ aChannelNumber: Int) {
        channelNumber = aChannelNumber
    }

    func defaultExchange() -> RMQExchange {
        return RMQExchange()
    }

    func queue(queueName: String, options: AMQQueueDeclareOptions) -> RMQQueue {
        if let foundQueue = queues[queueName] {
            return foundQueue;
        } else {
            let q = RMQQueue(name: queueName, channel: self, sender: SenderSpy())
            queues[queueName] = q
            return q
        }
    }

    func queueDeclare(queueName: String, options: AMQQueueDeclareOptions) -> AMQQueueDeclareOk {
        lastReceivedQueueDeclareOptions = options
        return AMQQueueDeclareOk(
            queue: AMQShortstr(queueName),
            messageCount: stubbedMessageCount,
            consumerCount: stubbedConsumerCount
        )
    }

    func basicConsume(queueName: String, consumer: (RMQMessage) -> Void) {
        lastReceivedBasicConsumeBlock = consumer
    }

    func handleFrameset(frameset: AMQFrameset) {
        lastReceivedFrameset = frameset
    }
}