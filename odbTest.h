#ifndef ODBTEST_H
#define ODBTEST_H

#include <string>
#include <list>
#include <memory>

#include <odb/core.hxx>
#include <odb/qt/lazy-ptr.hxx>

#pragma db object polymorphic
class Base
{
    friend class odb::access;
public:
    Base() = default;
    virtual ~Base() = default;

    #pragma db id type("VARCHAR(36)")
    std::string id;

};

#pragma db object
class Animal : public Base
{
    friend class odb::access;
public:
    Animal() = default;

    std::string nickname;
};

#pragma db object
class Man : public Base
{
    friend class odb::access;
public:
    Man() = default;

    std::string name;
    std::list<QSharedPointer<Animal>> pets;
};


#endif // ODBTEST_H
