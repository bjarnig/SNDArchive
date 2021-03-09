const readdirp = require('readdirp');
const { Sequelize, DataTypes } = require('sequelize');
const Op = Sequelize.Op;
const osc = require('osc');
const sequelize = {};
const Sound = {};
const Segment = {};

// - DB init -

function init(name) {

    sequelize[name] = new Sequelize({
        dialect: 'sqlite',
        storage: `./db/${name}.db`
    });

    async function connect() {
        try {
            await sequelize[name].authenticate();
            console.log(`=> Connection to db: ${name} established.`);
        } catch (error) {
            console.error('## Unable to connect to the database:', error);
        }
    };
    
    connect();

    // - Entities -

    Sound[name] = sequelize[name].define('Sound', {
        name: {
            type: DataTypes.STRING,
            allowNull: false
        },
        path: {
            type: DataTypes.STRING
        },
        dir: {
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
        },
        specFlatness: {
            type: DataTypes.NUMBER
        },
        loudness: {
            type: DataTypes.NUMBER
        },
        fFTSpread: {
            type: DataTypes.NUMBER
        },
        sensoryDissonance: {
            type: DataTypes.NUMBER
        },
        transient: {
            type: DataTypes.NUMBER
        }
    });

    Sound[name].sync();

    Segment[name] = sequelize[name].define('Segment', {
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
        },
        specFlatness: {
            type: DataTypes.NUMBER
        },
        loudness: {
            type: DataTypes.NUMBER
        },
        fFTSpread: {
            type: DataTypes.NUMBER
        },
        sensoryDissonance: {
            type: DataTypes.NUMBER
        },
        transient: {
            type: DataTypes.NUMBER
        }
    });

    Segment[name].belongsTo(Sound[name]);
    Segment[name].sync();
}

console.log(" ## SNDArchive ## ");

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

function scan(n, folder) {
    console.log('## API:scan');
    console.log(folder);
    readdirp(folder, {fileFilter: '*.wav', alwaysStat: true})
    .on('data', (entry) => {
        const {path, stats: {size}} = entry;
        const split = path.split('/');
        let name = split[split.length-1];
        let dir = split.join('/').replace(`/${name}`, '');

        console.log(path);
        console.log(name);
        console.log(dir);
        console.log(`${JSON.stringify({folder, path, name, dir, size})}`);
        Sound[n].create({ name: name, dir : dir, path : folder +'/'+ path });
    })
    .on('error', error => console.error('fatal error', error))
    .on('end', () => console.log('done'));
} 

function clear(n) {
    console.log('## API:clear');
    if(Sound[n]) {
        Sound[n].destroy({ where: {}, truncate: true });
    }

    if(Segment[n]) {
        Segment[n].destroy({ where: {}, truncate: true });
    }
} 

function clearInit(n) {
    console.log('## API:clearInit');
    clear(n);
    init(n);
} 

function reply(msg) {
    console.log('## API:reply');
    console.log(msg.address, msg.args, "to", udpPort.options.remoteAddress + ":" + udpPort.options.remotePort);
    udpPort.send(msg);
}

async function findAll(n) {
    console.log('## API:findAll');
    console.log(n);

    const sounds = await Sound[n].findAll();
    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: sounds.map(x => x.dir +'/'+ x.name)
        }]
    });
};

async function findOne(n, name) {
    console.log('## API:findOne');
    const sound = await Sound[n].findOne({ where: { name: name } });
    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: sound.name
        }]
    });
}

async function findSome(n) {
    console.log('## API:findSome');
    const segments = await Segment[n].findAll({
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

async function findTop(n, param, count) {
    console.log('## API:findTop');
    const segments = await Segment[n].findAll({
        order: [ [ param, 'DESC' ] ],
        limit: count,
        include: Sound[n]
    });

    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: JSON.stringify(segments.map(x => [x.index,x.start,x.end,x.Sound.path]))
        }]
    });
}

async function findBottom(n, param, count) {
    console.log('## API:findBottom');
    const segments = await Segment[n].findAll({
        order: [ [ param, 'ASC' ] ],
        limit: count,
        include: Sound[n]
    });

    reply({
        address: "/sndarchive",
        args: [{
            type: "s",
            value: JSON.stringify(segments.map(x => [x.index,x.start,x.end,x.Sound.path]))
        }]
    });
}

async function sound(n, name, params, values) {
    console.log('## API:sound');            
    const sound = await Sound[n].findOne(
        { where: { name: name } }
    );

    params = JSON.parse(params);
    values = JSON.parse(values);

    params.forEach((element, i) => sound[element] = values[i]);
    await sound.save();
}

async function segment(n, name, params, values) {
    console.log('## API:segment'); 
    console.log(name); 
    const sound = await Sound[n].findOne({ where: { name: name } });
    await Segment[n].destroy({ where: { soundId : sound.id } });
    let segment = { SoundId : sound.id };

    console.log('async function segment');
    console.log(params);
    console.log(values);

    params = JSON.parse(params);
    values = JSON.parse(values);

    params.forEach((element, i) => segment[element] = values[i]);
    await Segment[n].create(segment);
}

// - Message handling -

udpPort.on("message", function (msg) {

    if (msg && msg.address && msg.address === "/sndarchive") {
        
        const args = msg.args;
        const action = args[0].value;
        const n = args[1].value;
         
        console.log(JSON.stringify(msg));

        switch (action) {
            case 'scan':
                scan(n, args[2].value); break;
            case 'clear':
                clear(n); break;
            case 'clearInit':
                clearInit(n); break;
            case 'init':
                init(n); break;
            case 'findAll':
                findAll(n); break;
            case 'findSome':
                findSome(n); break;
            case 'findTop':
                findTop(n, args[2].value, args[3].value); break;
            case 'findBottom':
                findBottom(n, args[2].value, args[3].value); break;
            case 'findOne':
                findOne(n, args[2].value); break;
            case 'sound':
                sound(n, args[2].value, args[3].value, args[4].value); break;
            case 'segment':
                segment(n, args[2].value, args[3].value, args[4].value); break;
            default:
                console.log(`No handler found for: ${action}.`);
        }
    }
});