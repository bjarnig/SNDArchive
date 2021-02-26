
const { Sequelize, DataTypes } = require('sequelize');
const Op = Sequelize.Op;
const osc = require('osc');
const fs = require('fs');
const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './db/sndarchive.db'
});

// - DB init -

async function connect() {
    try {
        await sequelize.authenticate();
        console.log('Connection has been established successfully.');
    } catch (error) {
        console.error('Unable to connect to the database:', error);
    }
};

connect();

// - Entities -

const Sound = sequelize.define('Sound', {
    name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    path: {
        type: DataTypes.STRING
    },
    tartini: {
        type: DataTypes.NUMBER
    },
    spectralEntropy: {
        type: DataTypes.NUMBER
    },
    spectralCentroid: {
        type: DataTypes.NUMBER
    }
});

Sound.sync();

const Segment = sequelize.define('Segment', {
    index: {
        type: DataTypes.NUMBER
    },
    start: {
        type: DataTypes.NUMBER
    },
    end: {
        type: DataTypes.NUMBER
    },
    tartini: {
        type: DataTypes.NUMBER
    },
    spectralEntropy: {
        type: DataTypes.NUMBER
    },
    spectralCentroid: {
        type: DataTypes.NUMBER
    }
});

Segment.belongsTo(Sound);
Segment.sync();

// - Utils -

function readFiles(dirname, onFileContent, onError) {
    fs.readdir(dirname, function (err, filenames) {
        if (err) { onError(err); return; }
        
        filenames.forEach(function (filename) {
            if(filename && filename.endsWith(".wav")) {
                fs.readFile(dirname + filename, 'utf-8', function (err, content) {
                    if (err) { onError(err); return; }
                    onFileContent(filename, content);
                });
            }
        });
    });
}

// - OSC -

const udpPort = new osc.UDPPort({
    // This is the port we're listening on.
    localAddress: "127.0.0.1",
    localPort: 57121,

    // This is where sclang is listening for OSC messages.
    remoteAddress: "127.0.0.1",
    remotePort: 57120,
    metadata: true
});

udpPort.open();

// - API -

function scan(folder) {
    console.log('## API:scan');
    readFiles(folder, function (item) {
        Sound.create({ name: item, path : folder });
    });
} 

function clear() {
    console.log('## API:clear');
    Sound.destroy({ where: {}, truncate: true });
    Segment.destroy({ where: {}, truncate: true });
} 

function reply(msg) {
    console.log('## API:reply');
    console.log(msg.address, msg.args, "to", udpPort.options.remoteAddress + ":" + udpPort.options.remotePort);
    udpPort.send(msg);
}

async function findAll() {
    console.log('## API:findAll');
    const sounds = await Sound.findAll();
    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: sounds.map(x => x.name)
        }]
    });
};

async function findOne(name) {
    console.log('## API:findOne');
    const sound = await Sound.findOne({ where: { name: name } });
    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: sound.name
        }]
    });
}

async function findSome() {
    console.log('## API:findSome');
    const segments = await Segment.findAll({
        // where: {
        //     // spectralCentroid: {
        //     //     [Op.gte]: 0
        //     // }
        // },
        order: [ [ 'tartini', 'DESC' ] ],
        limit: 10,
        include: Sound
    });

    segments.sort(function (a, b) {
        return a.spectralCentroid - b.spectralCentroid;
    });

    if(segments.size > 10) {
        segments = segments.slice(0,10);
    }

    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: JSON.stringify(segments.map(x => [x.index,x.start,x.end,x.Sound.path + x.Sound.name]))
        }]
    });
}

async function findTop(param, count) {
    console.log('## API:findTop');
    const segments = await Segment.findAll({
        order: [ [ param, 'DESC' ] ],
        limit: count,
        include: Sound
    });

    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: JSON.stringify(segments.map(x => [x.index,x.start,x.end,x.Sound.path + x.Sound.name]))
        }]
    });
}

async function findBottom(param, count) {
    console.log('## API:findBottom');
    const segments = await Segment.findAll({
        order: [ [ param, 'ASC' ] ],
        limit: count,
        include: Sound
    });

    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: JSON.stringify(segments.map(x => [x.index,x.start,x.end,x.Sound.path + x.Sound.name]))
        }]
    });
}

async function sound(name, params, values) {
    console.log('## API:sound');            
    const sound = await Sound.findOne(
        { where: { name: name } }
    );

    params = JSON.parse(params);
    values = JSON.parse(values);

    params.forEach((element, i) => sound[element] = values[i]);
    await sound.save();
}

async function segment(name, params, values) {
    console.log('## API:segment'); 
    const sound = await Sound.findOne({ where: { name: name } });
    await Segment.destroy({ where: { soundId : sound.id } });
    let segment = { SoundId : sound.id };

    params = JSON.parse(params);
    values = JSON.parse(values);
    params.forEach((element, i) => segment[element] = values[i]);
    await Segment.create(segment);
}

// - Message handling -

udpPort.on("message", function (msg) {

    if (msg && msg.address && msg.address === "/sndarchive") {
        
        const args = msg.args;
        const action = args[0].value;
         
        console.log(JSON.stringify(msg));

        switch (action) {
            case 'scan':
                scan(args[1].value); break;
            case 'clear':
                clear(); break;
            case 'findAll':
                findAll(); break;
            case 'findSome':
                findSome(); break;
            case 'findTop':
                findTop(args[1].value, args[2].value); break;
            case 'findBottom':
                findBottom(args[1].value, args[2].value); break;
            case 'findOne':
                findOne(args[1].value); break;
            case 'sound':
                sound(args[1].value, args[2].value, args[3].value); break;
            case 'segment':
                segment(args[1].value, args[2].value, args[3].value); break;
            default:
                console.log(`No handler found for: ${action}.`);
        }
    }
});