#include <QCoreApplication>
#include <qdatetime.h>
#include <qdebug.h>
#include "odb/schema-catalog.hxx"
#include "odb/mysql/database.hxx"
#include "odbTest.h"
#include "odbTest-odb.hxx"

int main()
{
    Man man;
    man.id = "0b5ee0ec-314b-4c91-a57a-998097ecdbde";
    man.name = "Jon";

    for(int i = 0; i < 5; ++i)
    {
        auto& animal = man.pets.emplace_back();
        animal = QSharedPointer<Animal>::create();
        animal->id = std::to_string(i);
        animal->nickname = "pet_" + std::to_string(i);
    }

    QSharedPointer<odb::database> db(new odb::mysql::database ("victer", "777777", "test", "192.168.122.76"));

    odb::transaction t (db->begin());
    odb::schema_catalog::drop_schema(*db);
    odb::schema_catalog::create_schema(*db);
    t.commit();

    t.reset(db->begin());
    auto rr = db->persist(man);
    t.commit();

    t.reset(db->begin());
    odb::result r (db->query<Man>());

    for (auto i = r.begin (); i != r.end (); ++i)
    {
        qDebug() << "man id: " << i->id.c_str() << "man name:"  << i->name.c_str();
        for(const auto& pet: i->pets)
            qDebug() << "\tpet id: " << pet->id.c_str() << "pet nicname:"  << pet->nickname.c_str();
    }
    t.commit ();
    return 0;
}
