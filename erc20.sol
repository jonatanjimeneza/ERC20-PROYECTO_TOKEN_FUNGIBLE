// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

//Importación de modulos que necesitaremos para este proyecto.
import "@openzeppelin/contracts@4.4.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.4.2/access/Ownable.sol";

    // ==================================
    // Uso del ERC-20 con OpenZeppelin
    // Creación del Token ERC20
    // Gestión del token ERC20
    // Implentación de Tokens ERC20 en un entorno
    // Funciones avanzadas 
    // ==================================

//Creación de nuestro Smart Contract - Ejemplo academia de cursos online.
contract Academy is ERC20, Ownable{

    // ==================================
    // Declaraciones Iniciales
    // ==================================

    //Constructor del token ERC20
    constructor() ERC20("Courses", "CS"){
        //Utilizamos la función mint para asignar estos tokens a una dirección en este caso al smart contract.
        //Para que todo este regulado por el smart contract pero tambien podriamos ponerlo como msg.sender.
        _mint(address(this),10000);
    }

    //Estructura de datos
    struct customer {
        uint256 tokens_buyed;
        string [] enrolled_courses;
    }

    // Mapping
    mapping (address => customer) public Customers;

    // ==================================
    // Gestión del Token
    // ==================================

    //Función para establecer el precio del token 
    function priceTokens( uint256 _numberTokens) internal pure returns(uint256){
        //Esta función nos devuelve el numero de tokens que queramos por el precio que establezcamos.
        return _numberTokens * (1 ether);
    }

    //Función para visualizar el balance de un cliente
    function balanceTokens(address _account) public view returns (uint256){
        //Función que ya importamos con las librerias de openzeppelin.
        return balanceOf(_account);
    }

    //Función para mintear más tokens. 
    function mint(uint256 _amount) public onlyOwner{
        _mint(address(this),_amount);
    }

    //Función para comprar tokens como cliente
    function buyTokens(uint _numberTokens) public payable{
        uint256 cost = priceTokens(_numberTokens);
        require(msg.value >= cost, "Compra menos Tokens o paga con mas Ethers.");
        uint256 balance = balanceOf(address(this));
        require(_numberTokens <= balance, "Compra menos numeros de Tokens");
        uint256 returnValue = msg.value - cost;
        payable(msg.sender).transfer(returnValue);
        _transfer(address(this), msg.sender, _numberTokens);
        Customers[msg.sender].tokens_buyed += _numberTokens;
    }

    //Funcion para devolver o cambiar los tokens por ethers
    function tokensEthers(uint256 _numberTokens) public payable{
        require(_numberTokens > 0, "No tienes tokens.");
        require(_numberTokens <= balanceTokens(msg.sender), "No tienes tokens a devolver");
        _transfer(msg.sender, address(this), _numberTokens);
        payable(msg.sender).transfer(priceTokens(_numberTokens));
    }

    // ==================================
    // Gestión de la Academia o cualquier compañia
    // ==================================

    //Eventos
    event enjoy_course ( string, uint256, address);
    event new_course (string, uint256);
    event delete_course (string);

    //Estructura de datos
    struct course{
        string course_name;
        uint256 course_price;
        bool course_status;
    }

    //Mapping
    mapping(string => course) public MappingCourses;

    //Array
    string [] Courses;

    //Función para incorporar nuevos cursos a la academia
    function newCourse (string memory _course_name, uint256 _course_price) public onlyOwner{
        MappingCourses[_course_name] = course(_course_name, _course_price, true);
        Courses.push(_course_name);
        emit new_course(_course_name,_course_price);
    }

    //Función para eliminar un curso de la academia
    function deleteCourse(string memory _course_name) public onlyOwner{
        MappingCourses[_course_name].course_status = false;
        emit delete_course(_course_name);
    }

    //Función para comprar y acceder al curso
    function accessCourse(string memory _course_name) public{
        uint256 course_tokens = MappingCourses[_course_name].course_price;
        require(MappingCourses[_course_name].course_status==true, "Este curso no esta disponible");
        require(course_tokens <= balanceTokens(msg.sender), "Necesitas mas tokens para acceder al curso");
        _transfer(msg.sender, address(this), course_tokens);
        Customers[msg.sender].enrolled_courses.push(_course_name);
        emit enjoy_course(_course_name,course_tokens, msg.sender);
    }

    // ==================================
    // Guardar información relevante
    // ==================================

    //Función para visualizar el historial de cursos de un cliente
    function courseHistory(address _account)public view returns(string [] memory){
        return Customers[_account].enrolled_courses;
    }

    //Función para visualizar cursos actualmente disponibles
    function courses_availables()public view returns(string [] memory){
        return Courses;
    }
}
