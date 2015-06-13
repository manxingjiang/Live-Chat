var mongoose  = require('mongoose');
var Schema    = mongoose.Schema;
var ObjectId  = Schema.ObjectId;
var BaseModel = require("./base_model");

var TopicCollectSchema = new Schema({
    user_id: {type: ObjectId},
    topic_id: {type: ObjectId},
    create_at: {type: Date, default: Date.now}
});

TopicCollectSchema.plugin(BaseModel);
mongoose.model('TopicCollect',TopicCollectSchema)